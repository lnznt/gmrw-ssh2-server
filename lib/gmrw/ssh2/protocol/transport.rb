# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/alternative/active_support'
require 'gmrw/ssh2/protocol/reader'
require 'gmrw/ssh2/protocol/writer'
require 'gmrw/ssh2/protocol/exception'
require 'gmrw/ssh2/message/catalog'
require 'gmrw/ssh2/algorithm/kex'
require 'gmrw/ssh2/algorithm/host_key'

class GMRW::SSH2::Protocol::Transport
  include GMRW
  include Utils::Loggable
  include SSH2::Protocol::ErrorHandling

  attr_reader :connection
  property_ro :id, 'connection.object_id'

  def initialize(conn)
    @connection = conn
  end

  def logger=(*)
    super.tap {|l| l.format {|*s| "[#{id}] #{s.map(&:to_s) * ': '}" }}
  end


  property_ro :reader, 'SSH2::Protocol::Reader.new(self)' ; alias peer  reader
  property_ro :writer, 'SSH2::Protocol::Writer.new(self)' ; alias local writer

  delegate :recv_message, :poll_message, :to => :reader
  delegate :send_message,                :to => :writer

  abstract_method :client
  abstract_method :server


  property_ro :message_catalog,
                'SSH2::Message::Catalog.new {|ct| ct.logger = logger }'
  delegate :permit, :change_algorithm, :to => :message_catalog


  property_ro :algorithm, 'Struct.new(:kex, :host_key).new'

  property :kex
  property :host_key


  def start
    info( "SSH service start" )

    serve

  rescue => e
    fatal( "#{e.class}: #{e}" )
    debug{|l| e.backtrace.each {|bt| l << ( bt >> 2 ) } }
    e.call(self) rescue nil

  ensure
    connection.shutdown rescue nil
    connection.close    rescue nil
    info( "SSH service terminated" )
  end

  private
  abstract_method :serve
  
  #
  # :section: Protocol Version Exchange
  #
  def protocol_version_exchange
    local.version.compatible?(peer.version) or
        die :PROTOCOL_VERSION_NOT_SUPPORTED, "#{peer.version}"

    info( "local version: #{local.version}" )
    info( "peer  version: #{peer. version}" )
  end

  #
  # :section: Algorithm Negotiation
  #
  def send_kexinit
    send_message :kexinit, [
        :kex_algorithms,
        :server_host_key_algorithms,
        :encryption_algorithms_client_to_server,
        :encryption_algorithms_server_to_client,
        :mac_algorithms_client_to_server,
        :mac_algorithms_server_to_client,
        :compression_algorithms_client_to_server,
        :compression_algorithms_server_to_client  ].map {|name|
            [name, SSH2.config.algorithms[name.to_s] ]
        }.to_hash
  end

  def negotiate_algorithms
    algorithm.kex               = negotiate(:kex_algorithms)
    algorithm.host_key          = negotiate(:server_host_key_algorithms)
    client.algorithm.cipher     = negotiate(:encryption_algorithms_client_to_server)
    server.algorithm.cipher     = negotiate(:encryption_algorithms_server_to_client)
    client.algorithm.hmac       = negotiate(:mac_algorithms_client_to_server)
    server.algorithm.hmac       = negotiate(:mac_algorithms_server_to_client)
    client.algorithm.compressor = negotiate(:compression_algorithms_client_to_server)
    server.algorithm.compressor = negotiate(:compression_algorithms_server_to_client)

    debug( "kex               : #{algorithm.kex}"               )
    debug( "host_key          : #{algorithm.host_key}"          )
    debug( "client.cipher     : #{client.algorithm.cipher}"     )
    debug( "server.cipher     : #{server.algorithm.cipher}"     )
    debug( "client.hmac       : #{client.algorithm.hmac}"       )
    debug( "server.hmac       : #{server.algorithm.hmac}"       )
    debug( "client.compressor : #{client.algorithm.compressor}" )
    debug( "server.compressor : #{server.algorithm.compressor}" )

    kex( SSH2::Algorithm::Kex[algorithm.kex] )
    host_key( SSH2::Algorithm::HostKey[algorithm.host_key] )
  end

  def negotiate(name)
    client.message(:kexinit)[name].find   {|a|
    server.message(:kexinit)[name].include?(a)}
  end

  #
  # :section: Key Exchange
  #
  def do_kex
    @k, @hash, = kex.start(self)
    @session_id ||= @hash
  end

  def digest(data, len)
    ( host_key.digester.digest(@k + @hash + data) )[0, len]
  end

  def gen_key(salt, key_len)
    key = digest(salt + @session_id, key_len)
    key << digest(key, key_len - key.length) while key.length < key_len
    key
  end

  def taking_keys_into_use
    client.taking_keys_into_use(:iv => "A", :key => "C", :mac => "E")
    server.taking_keys_into_use(:iv => "B", :key => "D", :mac => "F")
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

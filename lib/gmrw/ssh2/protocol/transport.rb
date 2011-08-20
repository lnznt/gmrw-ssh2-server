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
require 'gmrw/ssh2/message/catalog'

class GMRW::SSH2::Protocol::Transport
  include GMRW
  include Utils::Loggable

  def initialize(conn)
    @connection = conn
  end

  attr_reader :connection

  property_ro :id, 'connection.object_id'

  def logger=(*)
    super.tap do |l|
      l.format {|*s| "[#{id}] #{s.map(&:to_s).join(': ')}" }
    end
  end

  property_ro :reader, 'SSH2::Protocol::Reader.new(self)'
  property_ro :writer, 'SSH2::Protocol::Writer.new(self)'

  delegate :poll_message, :to => :reader
  delegate :send_message, :to => :writer

  property_ro :peer,  :reader
  property_ro :local, :writer

  def client ; raise NotImplementedError, 'client' ; end
  def server ; raise NotImplementedError, 'server' ; end

  def config ; raise NotImplementedError, 'config' ; end

  property_ro :message_catalog,
                'SSH2::Message::Catalog.new {|ct| ct.logger = logger }'

  delegate :permit, :to => :message_catalog

  property_ro :algorithm, 'Struct.new(:kex, :host_key).new'

  def start
    info( "SSH service start" )

    version_exchange

    serve

  rescue => e
    fatal( "#{e.class}: #{e}" )
    debug{|l| e.backtrace.each {|bt| l << ( bt >> 2 ) } }

  ensure
    connection.shutdown rescue nil
    connection.close    rescue nil
    info( "SSH service terminated" )
  end

  private
  def serve ; raise NotImplementedError, 'serve' ; end

  def version_exchange
    local.version.compatible?(peer.version) or
        raise "unexpected SSH Version: #{peer.version}"

    info( "local version: #{local.version}" )
    info( "peer  version: #{peer. version}" )
  end

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
            [name, config.algorithms[name.to_s] ]
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

    message_catalog.change_algorithm :kex => algorithm.kex
  end

  def negotiate(name)
    client.message(:kexinit)[name].find   {|a|
    server.message(:kexinit)[name].include?(a)}
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

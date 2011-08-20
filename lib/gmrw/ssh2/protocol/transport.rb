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

class GMRW::SSH2::Protocol::Transport
  include GMRW
  include Utils::Loggable
  include SSH2::Protocol::ErrorHandling

  def initialize(conn)
    @connection = conn
  end

  attr_reader :connection

  property_ro :id, 'connection.object_id'

  def logger=(*)
    super.tap {|l| l.format {|*s| "[#{id}] #{s.map(&:to_s) * ': '}" }}
  end

  property_ro :reader, 'SSH2::Protocol::Reader.new(self)'
  property_ro :writer, 'SSH2::Protocol::Writer.new(self)'

  delegate :recv_message, :poll_message, :to => :reader
  delegate :send_message,                :to => :writer

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

    local.version.compatible?(peer.version) or
        die :PROTOCOL_VERSION_NOT_SUPPORTED, "#{peer.version}"
    info( "local version: #{local.version}" )
    info( "peer  version: #{peer. version}" )

    serve # SSH service

  rescue => e
    fatal( "#{e.class}: #{e}" )
    debug{|l| e.backtrace.each {|bt| l << ( bt >> 2 ) } }
    e.call(self) if e.respond_to?(:call)

  ensure
    connection.shutdown rescue nil
    connection.close    rescue nil
    info( "SSH service terminated" )
  end

  private
  def serve ; raise NotImplementedError, 'serve' ; end

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

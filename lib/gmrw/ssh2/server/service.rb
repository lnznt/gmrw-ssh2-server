# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/alternative/active_support'
require 'gmrw/ssh2/server/reader'
require 'gmrw/ssh2/server/writer'
require 'gmrw/ssh2/message/catalog'
require 'gmrw/ssh2/server/config'

class GMRW::SSH2::Server::Service
  include GMRW::Utils::Loggable
  include GMRW::SSH2

  def initialize(conn)
    @connection = conn
  end

  attr_reader :connection

  def logger=(*)
    super.tap do |l|
      l.format {|*s| "[#{connection.object_id}] #{s.map(&:to_s).join(': ')}" }
    end
  end

  property_ro :message_catalog, 'Message::Catalog.new {|ct| ct.logger = logger }'
  property_ro :algorithm, 'Struct.new(:kex, :host_key).new'

  property_ro :reader, 'Server::Reader.new(self)'
  property_ro :writer, 'Server::Writer.new(self)'

  property_ro :peer,  :reader
  property_ro :local, :writer

  property_ro :client, :peer
  property_ro :server, :local

  property_ro :config, 'Server::Config'

  delegate :poll_message, :to => :reader
  delegate :send_message, :to => :writer

  def start
    info( "SSH service start" )

    version_exchange

    message_catalog.permit { true } # TODO: 取りあえず全部許可

    key_exchange

    #
    # TODO : SSH プロトコルの実装
    #
    fatal( "SORRY! Not implement yet. quit." )

  rescue => e
    fatal( "#{e.class}: #{e}" )
    debug{|l| e.backtrace.each {|bt| l << ( bt >> 2 ) } }

  ensure
    connection.shutdown rescue nil
    connection.close    rescue nil
    info( "SSH service terminated" )
  end

  private
  def version_exchange
    local.version.compatible?(peer.version) or
        raise "unexpected SSH Version: #{peer.version}"

    info( "local version: #{local.version}" )
    info( "peer  version: #{peer. version}" )
  end

  def key_exchange
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

    negotiate_algorithms

    #
    # TODO: 実装続き
    #
    poll_message  # DUMMY
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

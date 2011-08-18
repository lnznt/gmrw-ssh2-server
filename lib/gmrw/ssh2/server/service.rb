# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/alternative/active_support'
require 'gmrw/ssh2/server/reader'
require 'gmrw/ssh2/server/writer'
require 'gmrw/ssh2/message/catalog'

class GMRW::SSH2::Server::Service
  include GMRW::Utils::Loggable

  def initialize(conn)
    @connection = conn
  end

  attr_reader :connection

  def logger=(*)
    super.tap do |l|
      l.format {|*s| "[#{connection.object_id}] #{s.map(&:to_s).join(': ')}" }
    end
  end

  property_ro :message_catalog, 'GMRW::SSH2::Message::Catalog.new'

  property_ro :reader, 'GMRW::SSH2::Server::Reader.new(self)'
  property_ro :writer, 'GMRW::SSH2::Server::Writer.new(self)'

  property_ro :peer,   :reader
  property_ro :local,  :writer

  property_ro :client, :peer
  property_ro :server, :local

  delegate :poll_message, :to => :reader
  delegate :send_message, :to => :writer

  def start
    info( "SSH service start" )

    version_exchange

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
        raise "SSH Version uncompatible: #{peer.version}"

    info( "server version: #{server.version}" )
    info( "client version: #{client.version}" )
  end

  def key_exchange
    send_message :kexinit

    negotiate_algorithms
    
    #
    # TODO: 実装続き
    #
  end

  def negotiate_algorithms
    [ :kex_algorithms                           ,
      :server_host_key_algorithms               ,
      :encryption_algorithms_client_to_server   ,
      :encryption_algorithms_server_to_client   ,
      :mac_algorithms_client_to_server          ,
      :mac_algorithms_server_to_client          ,
      :compression_algorithms_client_to_server  ,
      :compression_algorithms_server_to_client  ].each do |name|
        info( "#{name}: #{negotiate(name)}" )
    end

    #
    # TODO: 実装続き
    #

  end
  
  def negotiate(name)
    peer. message(:kexinit)[name].find   {|a|
    local.message(:kexinit)[name].include?(a)}
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/string'
require 'gmrw/extension/module'
require 'gmrw/utils/loggable'
require 'gmrw/alternative/active_support'
require 'gmrw/ssh2/server/constants'
require 'gmrw/ssh2/server/state'
require 'gmrw/ssh2/server/reader'
require 'gmrw/ssh2/server/writer'

class GMRW::SSH2::Server::Service
  include GMRW::Utils::Loggable
  include GMRW::SSH2

  def initialize(conn)
    @connection = conn
  end

  attr_reader :connection

  def id
    connection.object_id
  end

  def logger=(*)
    super.tap do |l|
      l.format {|*s| "[#{id}] #{s.map(&:to_s).join(': ')}" }
    end
  end

  property_ro :state,  'GMRW::SSH2::Server::State.new(self)'
  property_ro :reader, 'GMRW::SSH2::Server::Reader.new(self)'
  property_ro :writer, 'GMRW::SSH2::Server::Writer.new(self)'

  delegate :recv_message, :poll_message, :to => :reader
  delegate :message_catalog,             :to => :state

  property_ro :peer,   :reader
  property_ro :local,  :writer

  property_ro :client, :peer
  property_ro :server, :local

  def start
    info( "SSH service start" )

    version_exchange

    #
    # TODO : SSH プロトコルの実装
    #
    recv_message :kexinit
#    m = recv_message :kexinit ; debug( "!!#{m}!!" )
    fatal( "SORRY! Not implement yet. quit." )

  rescue => e
    fatal( "#{e.class}: #{e}" )
    debug {|l| e.backtrace.each {|bt| l << ( bt >> 2 ) } }

  ensure
    connection.shutdown rescue nil
    connection.close    rescue nil
    info( "SSH service terminated" )
  end

  private
  def version_exchange
    local.version.compatible?(peer.version) or
      raise "SSH Version uncompatible: #{peer.version.q}"

    info( "server version: #{server.version}" )
    info( "client version: #{client.version}" )
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/string'
require 'gmrw/extension/module'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/server/constants'
require 'gmrw/ssh2/server/exception'
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

  property_ro :reader, 'GMRW::SSH2::Server::Reader.new(self)'
  property_ro :writer, 'GMRW::SSH2::Server::Writer.new(self)'

  property_ro :peer,   :reader
  property_ro :local,  :writer

  property_ro :client, :peer
  property_ro :server, :local

  def start
    info( "SSH service start" )

    version_exchange

    reader.poll_message

    #
    # TODO : SSH プロトコルの実装
    #

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
      raise Server::PeerVersionError, peer.version.q

    info( "server version: #{server.version}" )
    info( "client version: #{client.version}" )
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

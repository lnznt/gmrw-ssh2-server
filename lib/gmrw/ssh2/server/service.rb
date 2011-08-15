# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/string'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/server/constants'

class GMRW::SSH2::Server::Service
  include GMRW::Utils::Loggable

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

  def start
    info( "SSH service start" )

    #
    # TODO : サービスの実装
    #

  rescue => e
    fatal( "#{e.class}: #{e}" )
    debug {|l| e.backtrace.each {|bt| l << ( bt >> 2 ) } }

  ensure
    connection.shutdown rescue nil
    connection.close    rescue nil
    info( "SSH service terminated" )
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

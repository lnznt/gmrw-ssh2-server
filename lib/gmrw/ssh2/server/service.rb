#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

require 'gmrw/extension/string'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/server/constants'

class GMRW::SSH2::Server::Service
  include GMRW::Utils::Loggable

  def initialize(conn)
    @connection = conn
  end

  attr_reader :connection

  def logger=(*)
    super.tap {|l| l.format {|s| "[#{connection.object_id}] #{s}" } }
  end

  def start
    log(:info) { "SSH service start" }

  rescue => e
    log(:fatal) { "#{e.class}: #{e}" }
    log:debug ; e.backtrace.each {|bt| log{ bt >> 2 } }

  ensure
    connection.shutdown rescue nil
    connection.close    rescue nil
    log(:info) { "SSH service terminated" }
  end

end

# vim:set ts=2 sw=2 et fenc=UTF-8:

# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/string'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/server/constants'

class GMRW::SSH2::Server::Side
  include GMRW::Utils::Loggable

  EOL = "\r\n"

  def initialize(service)
    @connection = service.connection
    @logger     = service.logger
  end

  private
  attr_reader :connection

  def gets
    (connection.gets || "") - /#{EOL}\Z/
  end

  def puts(s)
    write(s + EOL) ; s
  end

  def read(n)
    return "" if n <= 0

    connection.read(n)
  end

  def write(data)
    connection.write(data) and flush ; data
  end

  def flush
    connection.flush if connection.respond_to?(:flush)
  end

  def block_size
    8
  end

  property_ro :lengths, %-
    Struct.new(:packet_length).new(:packet_length => 4)
  -
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/module'
require 'gmrw/extension/string'
require 'gmrw/extension/integer'
require 'gmrw/utils/loggable'
require 'gmrw/utils/observable'
require 'gmrw/alternative/active_support'
require 'gmrw/ssh2/server/constants'

class GMRW::SSH2::Server::Side < Hash
  include GMRW::Utils::Loggable
  include GMRW::Utils::Observable

  EOL = "\r\n"

  def initialize(service)
    @service = service

    add_observer(:recv_message) { count(count.next % 0xffff_ffff) }
    add_observer(:send_message) { count(count.next % 0xffff_ffff) }
  end

  private
  delegate :connection, :logger, :message_catalog, :to => :@service
  property :count, '0'

  def puts(s)
    write(s + EOL) ; s
  end

  def write(data)
    connection.write(data) and flush ; data
  end

  def flush
    connection.flush if connection.respond_to?(:flush)
  end

  def gets
    (connection.gets || "") - /#{EOL}\Z/
  end

  def read(n)
    return "" if n <= 0

    connection.read(n)
  end

  def read_blocks(bytes)
    read(bytes.align(block_size))
  end

  def block_size
    8
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

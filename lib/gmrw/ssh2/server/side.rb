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

  def initialize(conn)
    @connection = conn
  end

  private
  attr_reader :connection

  def puts(s)
    connection.write s + EOL
    s
  end

  def gets
    (connection.gets || "") - /#{EOL}\Z/
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

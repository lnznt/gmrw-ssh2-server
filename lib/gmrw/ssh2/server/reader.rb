# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/module'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/server/constants'
require 'gmrw/ssh2/server/side'
require 'gmrw/ssh2/server/version_string'

class GMRW::SSH2::Server::Reader < GMRW::SSH2::Server::Side
  include GMRW::Utils::Loggable
  include GMRW::SSH2

  property_ro :version, 'Server::VersionString.new(gets)'
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/module'
require 'gmrw/ssh2/server/side'
require 'gmrw/ssh2/server/version_string'

class GMRW::SSH2::Server::Writer < GMRW::SSH2::Server::Side
  include GMRW::SSH2

  property_ro :version, 'puts Server::VersionString.new(Server::SSH_VERSION)'
end

# vim:set ts=2 sw=2 et fenc=utf-8:

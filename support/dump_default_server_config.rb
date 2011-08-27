#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'yaml'
require 'gmrw/ssh2/server/config'

print YAML.dump GMRW::SSH2::Server::Config.default

# vim:set ts=2 sw=2 et fenc=utf-8:

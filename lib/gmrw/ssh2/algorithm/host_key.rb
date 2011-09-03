# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/algorithm/host_key/rsa'
require 'gmrw/ssh2/algorithm/host_key/dsa'

module GMRW; module SSH2; module Algorithm
  module HostKey
    include GMRW
    extend self

    property_ro :algorithms, '{ "ssh-rsa" => RSAKey, "ssh-dss" => DSAKey }'

    def get(name)
      s = SSH2.config.host_key_files[name]
      algorithms[name].load(s) rescue raise "cannot create key #{name}"
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

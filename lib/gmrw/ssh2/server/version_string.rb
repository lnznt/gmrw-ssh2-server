# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/string'
require 'gmrw/ssh2/server/constants'

class GMRW::SSH2::Server::VersionString < String
  COMPONENTS = [:ssh_version, :protocol_version, :software_version, :comment]

  def component(name)
    (mapping(*COMPONENTS){ /^(SSH-(.+?))-(\S+)(?:\s(.+))?/ } || {})[name]
  end

  def compatible?(other)
    other.respond_to?(:ssh_version) && other.ssh_version == ssh_version
  end

  def respond_to?(name, *)
    COMPONENTS.include?(name) || super
  end

  private
  def method_missing(name, *)
    COMPONENTS.include?(name) ? component(name) : super
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'

module GMRW; module SSH2; module Protocol
  class VersionString < String
    def initialize(data={})
      return super if data.kind_of?(String)

      pv = data[:protocol_version] || '2.0'
      sv = data[:software_version] || '___'
      cm = data[:comment]

      super "SSH-#{pv}-#{sv}" + (cm ? cm >> 1 : "")
    end

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
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

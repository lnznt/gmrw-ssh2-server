# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/alternative/openssl'

module GMRW; module SSH2; module Algorithm
  module HostKey
    include GMRW
    extend self

    def get(name)
      f = open(SSH2.config.host_key_files[name])

      case name
        when 'ssh-rsa'; OpenSSL::PKey::RSA.new(f)
        when 'ssh-dss'; OpenSSL::PKey::DSA.new(f)
      end or raise "unknown host-key: #{name}"
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

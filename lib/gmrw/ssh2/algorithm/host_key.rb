# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/ssh2/algorithm/host_key/rsa_extension'
require 'gmrw/ssh2/algorithm/host_key/dsa_extension'

module GMRW; module SSH2; module Algorithm
  module HostKey
    include GMRW
    extend self

    def [](name)
      open(SSH2.config.host_key_files[name]) do |f|
        case name
          when 'ssh-rsa'
            OpenSSL::PKey::RSA.new(f).extend(SSH2::Algorithm::HostKey::RSAExtension)
            
          when 'ssh-dss'
            OpenSSL::PKey::DSA.new(f).extend(SSH2::Algorithm::HostKey::DSAExtension)

        end or raise "unknown host-key: #{name}"
      end 
    end

  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

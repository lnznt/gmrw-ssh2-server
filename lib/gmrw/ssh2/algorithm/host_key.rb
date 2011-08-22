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
    def get_host_key(host_key_name, key_files)
      case host_key_name
        when 'ssh-rsa'
          OpenSSL::PKey::RSA.new(open(key_files[host_key_name])).
                             extend(SSH2::Algorithm::HostKey::RSAExtension)
          
        when 'ssh-dss'
          OpenSSL::PKey::DSA.new(open(key_files[host_key_name])).
                             extend(SSH2::Algorithm::HostKey::DSAExtension)

        else
          raise "unknown host-key: #{host_key_name}"
      end
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'yaml'
require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/ssh2/config/default'

module GMRW; module SSH2;
  module Config
    extend self
    property_ro :algorithms, %-
      YAML.load open('../etc/algorithms.yaml'){|f| f.read } rescue Default.algorithms
    -

    property_ro :rsa_pubkey, %-
      OpenSSL::PKey::RSA.new open('../etc/rsa_pubkey.pem')
    -

    property_ro :rsa_privkey, %-
      OpenSSL::PKey::RSA.new open('../etc/rsa_privkey.pem')
    -
  end
end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

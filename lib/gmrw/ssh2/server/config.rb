# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'yaml'
require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/ssh2/algorithm'

module GMRW; module SSH2; module Server;
  module Config
    extend self
    conf_dir = '../etc/server'

    property_ro :port, '50022'

    property_ro :software_version,  '"ruby/gmrw_ssh2_server:v0.00a"'
    property_ro :version_comment,   '""'

    property_ro :algorithms, %-
      YAML.load open('#{conf_dir}/algorithms.yaml') {|f| f.read } rescue GMRW::SSH2::Algorithm.algorithms
    -

    property_ro :rsa_key, %-
      OpenSSL::PKey::RSA.new open('#{conf_dir}/rsa_key.pem')
    -
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

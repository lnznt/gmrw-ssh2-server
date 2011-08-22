# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'yaml'
require 'openssl'
require 'gmrw/extension/all'

module GMRW; module SSH2; module Server; module Config
  include GMRW
  extend self
  property_ro :default, 'Hash.new{{}}.merge(YAML.load Default)'

  property_ro :rsa_key, 'OpenSSL::PKey::RSA.new open(key_files[:rsa_key])'

  private
  def method_missing(name, *)
    default.key?(name) ? default[name] : super
  end

  Default = <<-DEFAULT
:version:
  :software_version: ruby/gmrw_ssh2_server(v0.00a)

:listen:
  :port: 50022

:paths:
  :conf_dir: ../etc/server

:key_files:
  :rsa_key: ../etc/server/rsa_key.pem

:algorithms:
  kex_algorithms:
#  - diffie-hellman-group-exchange-sha256
#  - diffie-hellman-group-exchange-sha1
  - diffie-hellman-group14-sha1
  - diffie-hellman-group1-sha1
  server_host_key_algorithms:
  - ssh-rsa
  - ssh-dss
  encryption_algorithms_client_to_server:
  - aes128-cbc
  - aes256-cbc
  - aes192-cbc
  - blowfish-cbc
  - cast128-cbc
  - 3des-cbc
  encryption_algorithms_server_to_client:
  - aes128-cbc
  - aes256-cbc
  - aes192-cbc
  - blowfish-cbc
  - cast128-cbc
  - 3des-cbc
  mac_algorithms_client_to_server:
  - hmac-sha1
  - hmac-sha1-96
  - hmac-md5
  - hmac-md5-96
  mac_algorithms_server_to_client:
  - hmac-sha1
  - hmac-sha1-96
  - hmac-md5
  - hmac-md5-96
  compression_algorithms_client_to_server:
  - none
  - zlib
  compression_algorithms_server_to_client:
  - none
  - zlib
DEFAULT
end; end; end; end

#p GMRW::SSH2::Server::Config.default[:listen]
#p GMRW::SSH2::Server::Config.listen

# vim:set ts=2 sw=2 et fenc=utf-8:

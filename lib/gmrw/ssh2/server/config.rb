# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'yaml'
require 'gmrw/extension/all'

module GMRW; module SSH2
  class << self ; property :config ; end

  module Server; module Config
    include GMRW
    extend self
    property_ro :default, 'Hash.new{{}}.merge(YAML.load Default)'

    private
    def method_missing(name, *)
      default.key?(name) ? default[name] : super
    end

    Default = <<-DEFAULT
:version:
  :software_version: ruby/gmrw_ssh2_server(v0.00a)

:listen:
  :port: 50022

:host_key_files:
  ssh-rsa: ../etc/server/rsa_key.pem
  ssh-dss: ../etc/server/dsa_key.pem

:openssl_name: 
  aes128-cbc: aes-128-cbc
  aes256-cbc: aes-256-cbc
  aes192-cbc: aes-192-cbc
  blowfish-cbc: bf-cbc
  cast128-cbc: cast-cbc
  3des-cbc: des-ede3-cbc

:algorithms:
  kex_algorithms:
  - diffie-hellman-group-exchange-sha256
  - diffie-hellman-group-exchange-sha1
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

# vim:set ts=2 sw=2 et fenc=utf-8:

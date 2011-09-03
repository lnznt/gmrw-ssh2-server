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
  ssh-rsa: ../etc/server/keys/rsa_key.pem
  ssh-dss: ../etc/server/keys/dsa_key.pem

:openssl_name: 
  aes128-cbc: aes-128-cbc
  aes256-cbc: aes-256-cbc
  aes192-cbc: aes-192-cbc
  blowfish-cbc: bf-cbc
  cast128-cbc: cast-cbc
  3des-cbc: des-ede3-cbc

:algorithms:
  :kex_algorithms:
  - diffie-hellman-group-exchange-sha256
  - diffie-hellman-group-exchange-sha1
  - diffie-hellman-group14-sha1
  - diffie-hellman-group1-sha1
  :server_host_key_algorithms:
  - ssh-dss
  - ssh-rsa
  :encryption_algorithms_client_to_server:
  - aes128-cbc
  - aes256-cbc
  - aes192-cbc
  - blowfish-cbc
  - cast128-cbc
  - 3des-cbc
  :encryption_algorithms_server_to_client:
  - aes128-cbc
  - aes256-cbc
  - aes192-cbc
  - blowfish-cbc
  - cast128-cbc
  - 3des-cbc
  :mac_algorithms_client_to_server:
  - hmac-sha1
  - hmac-sha1-96
  - hmac-md5
  - hmac-md5-96
  :mac_algorithms_server_to_client:
  - hmac-sha1
  - hmac-sha1-96
  - hmac-md5
  - hmac-md5-96
  :compression_algorithms_client_to_server:
  - none
  - zlib
  :compression_algorithms_server_to_client:
  - none
  - zlib

:oakley_group:
  # Group 14 [RFC3526 3. 2048-bit MODP Group]
  :group14:
    :bits: 2048
    :g: 2
    :p:
    - FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE649286651ECE45B3DC2007CB8A163BF0598DA48361C55D39A69163FA8FD24CF5F83655D23DCA3AD961C62F356208552BB9ED529077096966D670C354E4ABC9804F1746C08CA18217C32905E462E36CE3BE39E772C180E86039B2783A2EC07A28FB5C55DF06F4C52C9DE2BCBF6955817183995497CEA956AE515D2261898FA051015728E5A8AACAA68FFFFFFFFFFFFFFFF
    - 16

  # Group 1 [RFC2409 6.2 Second Oakley Group] (1024-bit MODP Group)
  :group1:
    :bits: 1024
    :g: 2
    :p:
    - FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E088A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B1FE649286651ECE65381FFFFFFFFFFFFFFFF
    - 16

:authentication:
#  - publickey
  - password

:users:
  guest1:
    :password: pass1
  guest2:
    :password: pass2
DEFAULT
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

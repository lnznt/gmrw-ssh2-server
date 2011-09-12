# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'

module GMRW; module SSH2; module Algorithm
  class Cipher
    include GMRW

    def_initialize :name
    property       :keys, 'Hash.new{{}}'

    property_ro :encrypt, 'crypt :encrypt'
    property_ro :decrypt, 'crypt :decrypt'

    forward [:block_size] => :cipher

    private
    def crypt(mode)
      cipher.send(mode)
      cipher.iv  = keys[:iv ][cipher.iv_len ]
      cipher.key = keys[:key][cipher.key_len]
      cipher.padding = 0

      proc {|s| (s && !s.empty?) ? cipher.update(s) : s }
    end

    property_ro :cipher,         'openssl_name ? openssl_cipher : none'
    property_ro :openssl_cipher, 'OpenSSL::Cipher.new(openssl_name)'
    property_ro :openssl_name,   'SSH2.config.openssl_name[name]'

    property_ro :none, 'Class.new { def update(s)         ; s ; end
                                    def method_missing(*) ; 8 ; end }.new'
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

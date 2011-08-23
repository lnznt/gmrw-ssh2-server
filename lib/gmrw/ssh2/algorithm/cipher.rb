# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/alternative/active_support'

module GMRW; module SSH2; module Algorithm
  module Cipher
    include GMRW
    extend self

    property_ro :block_size, 'Hash.new{|h,name| h[name] = new(name).block_size}'

    def new(name)
      OpenSSL::Cipher.new(SSH2.config.openssl_name[name])
    end

    #def get(enc_or_dec, cipher_name, gen_key, salt)
    def get(enc_or_dec, cipher_name, keys)
      cipher = new(cipher_name)
      cipher.send(enc_or_dec)
      cipher.padding = 0
      #cipher.iv  = gen_key[salt[:iv ], cipher.iv_len ]
      #cipher.key = gen_key[salt[:key], cipher.key_len]
      cipher.iv  = keys[:iv ][cipher.iv_len ]
      cipher.key = keys[:key][cipher.key_len]

      proc {|s| s.present? ? cipher.update(s) : s }
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'

module GMRW; module SSH2; module Algorithm
  module Cipher
    include GMRW
    extend self

    property_ro :block_size, 'Hash.new{|h,name| h[name] = new(name).block_size}'

    def new(name)
      OpenSSL::Cipher.new(SSH2.config.openssl_name[name])
    end

    def get(enc_or_dec, cipher_name, keys)
      cipher = new(cipher_name)
      cipher.send(enc_or_dec)
      cipher.padding = 0
      cipher.iv  = keys[:iv ][cipher.iv_len ]
      cipher.key = keys[:key][cipher.key_len]

      proc {|s| (s && !s.empty?) ? cipher.update(s) : s }
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

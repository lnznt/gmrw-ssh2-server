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

    #property_ro :block_size, 'Hash.new{|h,name| h[name] = new(name).block_size}'
    def block_size(name)
      name == 'none' ? 8 : new(name).block_size
    end

    def get_encrypt(*a) ; get(:encrypt, *a) ; end
    def get_decrypt(*a) ; get(:decrypt, *a) ; end

    private
    def get(enc_or_dec, name, keys)
      name == 'none' ? proc {|s| s } : get_cipher(enc_or_dec, name, keys)
    end

    def get_cipher(enc_or_dec, name, keys)
      cipher = new(name)
      cipher.send(enc_or_dec)
      cipher.padding = 0
      cipher.iv  = keys[:iv ][cipher.iv_len ]
      cipher.key = keys[:key][cipher.key_len]

      proc {|s| (s && !s.empty?) ? cipher.update(s) : s }
    end

    def new(name)
      OpenSSL::Cipher.new(SSH2.config.openssl_name[name])
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

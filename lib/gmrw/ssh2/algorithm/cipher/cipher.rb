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
    def get_cipher(encryption, cipher_name, iv_gen, key_gen)
      cipher = OpenSSL::Cipher.new(openssl_name(cipher_name))
      cipher.send(encryption)
      cipher.padding = 0
      cipher.iv  = iv_gen [cipher.iv_len ]
      cipher.key = key_gen[cipher.key_len]

      [
        proc {|data| data.present? ? cipher.update(data) : data },
        cipher.block_size
      ]
    end

    def openssl_name(name)
      case name
        when 'aes128-cbc'; 'aes-128-cbc'
      end
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

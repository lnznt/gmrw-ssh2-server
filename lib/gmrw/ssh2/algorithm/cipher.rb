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

    def block_size(name)
      name == 'none' ? 0 : new(name).block_size
    end

    def get(name, *a, &b)
      name == 'none' ? proc {|s| s } : get_cipher(name, *a, &b)
    end

    def get_cipher(name, keys)
      cipher = new(name)
      cipher.send(yield)
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

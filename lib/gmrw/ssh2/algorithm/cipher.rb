# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'

module GMRW; module SSH2; module Algorithm
  module Cipher
    include GMRW
    extend self

    property_ro :block_size, %-
      Hash.new {|h, name| h[name] = create(name).block_size }
    -

    def get(name, keys)
      cipher = create(name)
      cipher.send(yield)
      cipher.iv  = keys[:iv ][cipher.iv_len ]
      cipher.key = keys[:key][cipher.key_len]
      cipher.padding = 0

      proc {|s| (s && !s.empty?) ? cipher.update(s) : s }
    end

    private
    def create(name)
      name == 'none' ? none : OpenSSL::Cipher.new(SSH2.config.openssl_name[name])
    end

    property_ro :none, %-
      Class.new {
        def update(s)  ; s ; end
        def block_size ; 8 ; end
        def iv_len     ; 8 ; end
        def key_len    ; 8 ; end
        def method_missing(*) ; end
      }.new
    -
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

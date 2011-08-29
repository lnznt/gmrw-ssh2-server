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

    def block_size(name)
      new(name).block_size
    end

    def get(name, keys)
      cipher = new(name)
      cipher.send(yield)
      cipher.padding = 0
      cipher.iv  = keys[:iv ][cipher.iv_len ]
      cipher.key = keys[:key][cipher.key_len]

      proc {|s| (s && !s.empty?) ? cipher.update(s) : s }
    end

    def new(name)
      name == 'none' ? none : OpenSSL::Cipher.new(SSH2.config.openssl_name[name])
    end

    private
    property_ro :none, %-
      null.dup.extend(Module.new {
        def update(s)         ; s ; end
        def block_size        ; 8 ; end
        def iv_len            ; 8 ; end
        def key_len           ; 8 ; end
      })
    -
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

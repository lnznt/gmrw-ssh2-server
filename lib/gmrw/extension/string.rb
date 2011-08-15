# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'
require 'gmrw/extension/array'
require 'gmrw/alternative/active_support'

module GMRW::Extension
  mixin String do
    def remove(s)
      sub(s, '')
    end

    alias - remove

    def indent(n, s=' ')
      (s * n) + self    
    end

    alias >> indent

    def wrap(w)
      (w[0,1] || '') + self + (w[-1,1] || '')
    end

    alias ** wrap

    def q
      wrap("'")
    end

    def qq
      wrap('"')
    end

    def divide(n)
      [first(n), last(length - n)]
    end

    alias / divide

    def parse(pattern)
      (match(pattern) || [])[1..-1]
    end

    def mapping(*names)
      (parsed = parse(yield)) and parsed.mapping(*names)
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

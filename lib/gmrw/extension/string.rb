# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'
require 'gmrw/extension/integer'
require 'gmrw/extension/attribute/string_to'

module GMRW::Extension
  mixin String do
    def indent(n, s=' ')
      (s * n) + self    
    end

    alias >> indent

    def div(n=1)
      [self[0, n.minimum(0)], self[n.minimum(0)..-1]]
    end

    alias / div

    def bin
      to.bin
    end

    attribute :to, Attribute::StringTo
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

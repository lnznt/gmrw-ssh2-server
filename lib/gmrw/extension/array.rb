# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'
require 'gmrw/extension/attribute/array_to'

module GMRW::Extension
  mixin Array do
    def to_hash
      Hash[ *flatten(1) ]
    end

    def mapping(*keys)
      (keys.empty? ? (0...count) : keys).zip(self).to_hash
    end

    def cons(*a)
      Array(a) + self
    end

    def rjust(len, pad=nil)
      cons *(len > length ? [pad] * (len - length) : [])
    end

    attribute :to, Attribute::ArrayTo
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

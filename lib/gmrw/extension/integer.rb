# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'
require 'gmrw/extension/attribute/integer_bit'
require 'gmrw/extension/attribute/integer_pack'
require 'gmrw/extension/attribute/integer_to'

module GMRW::Extension
  mixin Integer do
    def count_per(n)
      (self + (n - 1)) / n
    end

    def align(n)
      count_per(n) * n
    end

    def maximum(n)
      self > n ? n : self
    end

    def minimum(n)
      self < n ? n : self
    end

    def negative?
      self < 0
    end

    def positive?
      self > 0
    end

    def signum
      positive? ?  1 :
      negative? ? -1 : 0
    end

    attribute :bit,  Attribute::IntegerBit
    attribute :pack, Attribute::IntegerPack
    attribute :to,   Attribute::IntegerTo
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

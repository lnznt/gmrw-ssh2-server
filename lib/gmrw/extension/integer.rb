# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'

module GMRW::Extension
  mixin Integer do
    def align(n)
      (self + (n - 1)).div(n) * n
    end

    def maximum(n)
      self > n ? n : self
    end

    def minimum(n)
      self < n ? n : self
    end

    def count_bit
      sprintf("%b", self).count("1")
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

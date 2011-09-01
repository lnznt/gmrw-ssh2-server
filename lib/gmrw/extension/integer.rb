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

    def bit
      @bit ||= Class.new {
        attr_accessor :this ; alias initialize this=

        def [](range)
          first = (range.respond_to?(:first) && range.first) || range
          last  = (range.respond_to?(:last ) && range.last ) || range

          [first, last].max.downto([first, last].min).reduce(0) {|n, i| n << 1 | this[i] }
        end

        def count
          sprintf("%b", this).count("1")
        end

        def div(bits)
          bits > 0 or raise ArgumentError, "#{bits}"

          mask = (1 << bits) - 1
          n = this
          a = []
          (a << (n & mask) ; n >>= bits) while n > 0
          a.empty? ? [0] : a.reverse
        end
      }.new(self)
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

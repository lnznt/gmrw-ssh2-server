# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'
require 'gmrw/extension/array'

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

    def bit
      @bit ||= Class.new {
        attr_accessor :this ; alias initialize this=

        def [](range)
          first = (range.respond_to?(:first) && range.first) || range
          last  = (range.respond_to?(:last ) && range.last ) || range

          ([first, last].max).downto([first, last].min).reduce(0) {|n, i| n << 1 | this[i] }
        end

        def set?(pos)
          this.bit[pos] == 1
        end

        def clear?(pos)
          this.bit[pos] == 0
        end

        def count
          sprintf("%b", this).count("1") * this.signum
        end

        def wise
          sprintf("%b", this).sub(/^\.+/, '').length * this.signum
        end

        def mask
          (1 << this) - 1
        end

        def div(bits=8, opts={})
          bits > 0 or raise ArgumentError, "#{bits}"

          n = this.negative? ? this.abs.bit.complement(bits) + 1 : this
          a = [] ; (a.unshift(n & bits.bit.mask) ; n >>= bits) while n > 0

          this.negative? && (a = a.rjust(this.abs.bit.wise.count_per(bits), 0))

          msb  = (bits - 1)
          lead = (!opts[:nolead] && this.positive? && a[0].bit.set?(msb))   ? [0]             :
                 (                  this.negative? && a[0].bit.clear?(msb)) ? [bits.bit.mask] : []

          lead + a
        end

        def complement(bits=8)
          bits > 0 or raise ArgumentError, "#{bits}"

          bs = div(bits, :nolead => true)
          ns = bs.empty? ? [0] : bs
          ns.map {|n| n ^ bits.bit.mask }.reduce(0) {|n, b| n << bits | b }
        end
      }.new(self)
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

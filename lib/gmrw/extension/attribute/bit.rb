# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/array'
require 'gmrw/extension/attribute'

class GMRW::Extension::Attribute
  module Bit
    def [](range)
      first = range.respond_to?(:first) ? range.first : range
      last  = range.respond_to?(:last ) ? range.last  : range

      high  = [first, last].max
      low   = [first, last].min

      (high.downto low).reduce(0) {|n, i| n << 1 | this[i] }
    end

    def let(range, b)
      width = range.respond_to?(:count) ? range.count : 1
      first = range.respond_to?(:first) ? range.first : range
      last  = range.respond_to?(:last ) ? range.last  : range
      low   = [first, last].min
      mask  = (width << low)

      (b == 0 || !b) ? (this & ~mask) : (this | mask)
    end

    def set?(pos)
      !clear?(pos)
    end

    def clear?(pos)
      self[pos] == 0
    end

    def set(pos)
      self.let(pos, 1)
    end

    def clear(pos)
      self.let(pos, 0)
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

    def bits(opts={})
      div(1, opts)
    end

    def complement(bits=8)
      bits > 0 or raise ArgumentError, "#{bits}"

      bs = div(bits, :nolead => true)
      ns = bs.empty? ? [0] : bs
      ns.map {|n| n ^ bits.bit.mask }.reduce(0) {|n, b| n << bits | b }
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

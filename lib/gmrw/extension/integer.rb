# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
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

    def count_bit(bit=1)
      sprintf("%b", self).count(bit.to_s)
    end

    def to_bignum
      OpenSSL::BN.new(to_s)
    end

=begin
    def positive?
      self > 0
    end

    def negative?
      self < 0
    end

    def zero_or_positive?
      zero? || positive?
    end

    def zero_or_negative?
      zero? || negative?
    end

    def signum
      positive? ?  1 :
      negative? ? -1 : 0
    end

    def negate
      self * -1
    end
=end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

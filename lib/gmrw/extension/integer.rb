# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'
require 'gmrw/extension/attribute/integer_bit'

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

    def to_BN
      OpenSSL::BN.new(to_s)
    end

    def to_asn1
      OpenSSL::ASN1::Integer.new(self)
    end

    def to_der
      to_asn1.to_der
    end

    def to_bytes
      bit.div(8)
    end

   def pack_uint8
      [self].pack("C")
    end

    alias pack_octet pack_uint8
    alias pack_byte  pack_uint8

    def pack_uint16
      [self].pack("n")
    end

    def pack_uint32
      [self].pack("N")
    end

    def pack_uint64
      [bit[63..32], bit[31..0]].pack("NN")
    end

    def pack_bin
      to_bytes.pack("C*")
    end

    attribute :bit,  Attribute::IntegerBit
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

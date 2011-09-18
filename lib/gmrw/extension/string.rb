# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/extension'
require 'gmrw/extension/integer'

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

    module BinaryString
      def to_i
        negative = (to_bytes[0] || 0).bit.set?(msb=7)
        n        = to_bytes.reduce(0) {|n,m| n << 8 | m }
        negative ? -(n.bit.complement + 1) : n
      end
    end

    def to_bin
      to_bytes.pack("C*").extend(BinaryString)
    end

    def to_bytes
      unpack("C*")
    end

    def to_uint8
      unpack("C")[0]
    end

    alias to_octet to_uint8
    alias to_byte  to_uint8

    def to_uint16
      unpack("n")[0]
    end

    def to_uint32
      unpack("N")[0]
    end

    def to_uint64
      unpack("NN").reduce {|n,m| n << 32 | m }
    end

    def to_BN(n=nil)
      n = {
        :mpint       =>  0,
        :mpi         =>  0,
        :binary      =>  2,
        :bin         =>  2,
        :decimal     => 10,
        :dec         => 10,
        :hexadecimal => 16,
        :hex         => 16,
      }[n] || n
      OpenSSL::BN.new(*[self, n].compact)
    end

    def to_packet(length_field_type=:uint32)
      ({
        :uint8  => length.pack_uint8,
        1       => length.pack_uint8,
        :uint16 => length.pack_uint16,
        2       => length.pack_uint16,
        :uint32 => length.pack_uint32,
        4       => length.pack_uint32,
        :uint64 => length.pack_uint64,
        8       => length.pack_uint64,
      }[length_field_type] || "") + self
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

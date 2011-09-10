# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/extension'
require 'gmrw/extension/object'
require 'gmrw/extension/integer'

class GMRW::Extension::Attribute
  module StringTo
    def packet(length_field_type=:uint32)
      (this.length.pack.try_send(length_field_type) || "") + this
    end

    def mpi
      negative = (this.to.bytes[0] || 0).bit.set?(msb=7)
      n        = this.to.bytes.reduce(0) {|n,m| n << 8 | m }
      negative ? -(n.bit.complement + 1) : n
    end

    def bin
      bytes.pack("C*")
    end

    def bytes
      this.unpack("C*")
    end

    def uint8
      this.unpack("C")[0]
    end

    alias octet uint8
    alias byte uint8

    def uint16
      this.unpack("n")[0]
    end

    def uint32
      this.unpack("N")[0]
    end

    def uint64
      this.unpack("NN").reduce {|n,m| n << 32 | m }
    end

    def bn(n=nil)
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
      OpenSSL::BN.new(*[this, n].compact) 
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

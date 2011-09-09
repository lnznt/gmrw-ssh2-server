# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/attribute'

class GMRW::Extension::Attribute
  module IntegerPack
    def uint8
      [this].pack("C")
    end

    alias octet uint8
    alias byte uint8

    def uint16
      [this].pack("n")
    end

    def uint32
      [this].pack("N")
    end

    def uint64
      [this.bit[63..32], this.bit[31..0]].pack("NN")
    end

    def bin
      this.bit.div(8).pack("C*")
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

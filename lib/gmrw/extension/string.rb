# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'
require 'gmrw/extension/object'
require 'gmrw/extension/array'
require 'gmrw/extension/integer'
require 'gmrw/extension/attribute/string_to'

module GMRW::Extension
  compatibility String do
    def at(pos)
      self[pos, 1]
    end
  end

  mixin String do
    def remove(s)
      sub(s, '')
    end

    alias - remove

    def indent(n, s=' ')
      (s * n) + self    
    end

    alias >> indent

    def wrap(*ws)
      w = ws.reduce(&:+)
      (w.at(0) || '') + self + (w.at(-1) || '')
    end

    alias ** wrap

    def q
      wrap("'")
    end

    def qq
      wrap('"')
    end

    def div(n=1)
      [self[0, n.minimum(0)], self[n.minimum(0)..-1]]
    end

    alias / div

    def parse(pattern)
      (match(pattern) || [])[1..-1]
    end

    def mapping(*names)
      parse(yield).try(:mapping, *names)
    end

    def bin
      to.bin
    end

    attribute :to, Attribute::StringTo
=begin
    def to_packet(length_field_type=:uint32)
      (length.pack.try_send(length_field_type) || "") + self
    end

    def to_bytes
      unpack("C*")
    end

    def pack_mpi
      negative = (to_bytes[0] || 0).bit.set?(msb=7)
      n        = to_bytes.reduce(0) {|n,m| n << 8 | m }
      negative ? -(n.bit.complement + 1) : n
    end

    def bin
      to_bytes.pack("C*")
    end
=end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

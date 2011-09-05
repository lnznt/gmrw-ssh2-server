# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'
require 'gmrw/extension/array'
require 'gmrw/extension/integer'

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
      (parsed = parse(yield)) && parsed.mapping(*names)
    end

    def to_packet(length_field_size=4)
      length_field = {
        0 => "",
        1 => [length].pack("C"),
        4 => [length].pack("N"),
        8 => [length.bit[63..32], length.bit[31..0]].pack("NN"),
      }[length_field_size] or raise ArgumentError, "#{length_field_size}"

      length_field + self
    end

    def pack_mpi
      negative = (unpack("C")[0] || 0)[msb=7] == 1
      n        = unpack("C*").reduce(0) {|n,m| n << 8 | m }
      negative ? -(n.bit.complement + 1) : n
    end

    def bin
      unpack("C*").pack("C*")
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

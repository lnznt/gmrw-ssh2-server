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

    def to_packet(length_field_type=:uint32)
      nvl(length.pack.try_send(length_field_type), "") + self
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

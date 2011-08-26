# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'
require 'gmrw/extension/all'

module GMRW::Extension
  compatibility String do
    def at(pos)
      self[pos, 1]
    end

    def camelize(first_letter_in_uppercase = true)
      first_letter_in_uppercase ? upper_camelize : lower_camelize
    end

    private
    def upper_camelize
      lower_camelize.sub(/./) { $&.upcase }
    end

    def lower_camelize
      path_to_namespace.gsub(/(?:_|(::))(.)/) { "#{$1}#{$2.upcase}" }
    end

    def path_to_namespace
      gsub(/\//, '::')
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
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'

module GMRW::Extension
  mixin Array do
    def to_hash
      Hash[ *flatten(1) ]
    end

    def mapping(*keys)
      (keys.empty? ? (0...count) : keys).zip(self).to_hash
    end

    def rjust(len, pad=nil)
      ([pad] * ((len > length) ? (len - length) : 0)) + self
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

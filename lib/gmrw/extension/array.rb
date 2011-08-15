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
      keys.empty? ? mapping_by_index : mapping_by_name(*keys)
    end

    def mapping_by_name(*names)
      names.zip(self).to_hash
    end

    def mapping_by_index
      (0...count).zip(self).to_hash
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

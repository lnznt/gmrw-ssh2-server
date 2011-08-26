# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'
require 'gmrw/extension/module'

module GMRW::Extension
  compatibility Object do
    def presence
      (self && !empty?) ? self : nil
    end

    def try(*a, &b)
      send(*a, &b)
    end
  end

  mixin Object do
    private
    property_ro :null, 'Class.new{ def method_missing(*) ; end }.new'
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

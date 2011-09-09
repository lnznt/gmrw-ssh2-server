# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'
require 'gmrw/extension/module'
require 'gmrw/extension/attribute'
require 'gmrw/extension/attribute/is'
require 'gmrw/extension/null'

module GMRW::Extension
  compatibility Object do
    def try(*a, &b)
      nil? ? nil : send(*a, &b)
    end
  end

  mixin Object do
    def try_send(name, *a, &b)
      (name && respond_to?(name)) ? send(name, *a, &b) : nil
    end

    attribute :is, Attribute::Is

    private
    property_ro :null, 'Null.instance'

    def nvl(val, replacement)
      val.nil? ? replacement : val
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

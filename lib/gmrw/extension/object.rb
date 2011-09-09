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
  mixin Object do
    attribute :is, Attribute::Is

    private
    property_ro :null, 'Null.instance'
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

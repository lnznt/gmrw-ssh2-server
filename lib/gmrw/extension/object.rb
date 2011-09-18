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

require 'singleton'

module GMRW::Extension
  class Null
    include Singleton
    private ; def method_missing(*) ; end
  end

  mixin Object do
    def try_send(name, *a, &b)
      (name && respond_to?(name)) ? send(name, *a, &b) : nil
    end

    attribute :is, Attribute::Is

    private
    property_ro :null, 'Null.instance'
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

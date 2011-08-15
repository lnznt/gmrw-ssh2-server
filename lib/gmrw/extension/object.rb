# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'
require 'gmrw/extension/module'

module GMRW::Extension
  mixin Object do
    def evaluate(&block)
      block.arity > 0 ? yield(self) : instance_eval(&block)
    end

    private
    property_ro :null, 'Class.new{ def method_missing(*) ; end }.new'
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

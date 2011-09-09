# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/module'

module GMRW
  module Extension
    class Attribute
      private
      def_initialize :this
    end

    mixin Module do
      def attribute(name, mod)
        module_eval %-
          property_ro :#{name}, 'Attribute.new(self).extend(#{mod.name})'
        -
      end
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

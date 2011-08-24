# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'forwardable'
require 'gmrw/extension/extension'

module GMRW::Extension
  mixin Forwardable do
    def forward(delegation)
      methods, to = delegation.each_pair.next
      def_delegators to, *methods
    end
  end
end

class Module
  include Forwardable
end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/module'
require 'gmrw/alternative/active_support'

module GMRW
  module SSH2
    module Message
      private
      property_ro :classes, {}
      delegate :[], :to => :classes
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

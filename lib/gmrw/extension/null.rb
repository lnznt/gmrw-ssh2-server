# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'singleton'
require 'gmrw/extension/extension'

module GMRW::Extension
  class Null
    include Singleton
    private ; def method_missing(*) ; end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

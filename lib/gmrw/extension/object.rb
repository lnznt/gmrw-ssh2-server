# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'

module GMRW::Extension
  mixin Object do
    private
    def null
      @null ||= Class.new{ def method_missing(*) ; end }.new
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

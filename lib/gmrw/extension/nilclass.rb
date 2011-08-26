# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'

module GMRW::Extension
  compatibility NilClass do
    def try(*) ; end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

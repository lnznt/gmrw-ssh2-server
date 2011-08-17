# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/utils/command'

class GMRW::Utils::Filter < GMRW::Utils::Command
  def call(*a, &b)
    all? {|f| f[*a, &b] }
  end
end

# vi:set ts=2 sw=2 et fenc=utf-8:

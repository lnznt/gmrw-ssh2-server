# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/command'

module GMRW::Utils::Observable
  property_ro :observers, 'Hash.new {|h,k| h[k] = GMRW::Utils::Command.new }'

  def add_observer(event, &block)
    observers[event] << block
  end

  def notify_observers(event, *a, &b)
    observers[event].call(*a, &b)
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

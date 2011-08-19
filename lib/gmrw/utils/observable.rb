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

  def add_observer(event, command=nil, &block)
    observers[event] << (command || block) if command || block
  end

  def notify_observers(event, *a, &b)
    observers[event][*a, &b]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

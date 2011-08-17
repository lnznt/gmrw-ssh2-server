# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/utils/counter'

counter = GMRW::Utils::Counter.new(:limit => 3)
counter.up
counter.up

p counter.count

counter.up

p counter.count

# vim:set ts=2 sw=2 et fenc=utf-8:

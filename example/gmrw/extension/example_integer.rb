# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/integer'

(-256..0).each do |n|
  p n.bit.div(8).map {|x| "%x" % x }
end
puts "--"
p 0.bit.div.map {|x| "%x" % x }
p 0x1234.bit.div.map {|x| "%x" % x }
p -0x1234.bit.div.map {|x| "%x" % x }
p 0x8000.bit.div.map {|x| "%x" % x }
p -0xbeef.bit.div.map {|x| "%x" % x }

# vim:set ts=2 sw=2 et fenc=utf-8:

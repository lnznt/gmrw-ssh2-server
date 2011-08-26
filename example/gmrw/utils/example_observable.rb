# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/utils/observable'

class C
  include GMRW::Utils::Observable

  def foo
    notify_observers(:world, "world")
  end
end

c = C.new
c.add_observer(:world) {|s,| puts "hello, #{s}" }

c.foo

# vim:set ts=2 sw=2 et fenc=utf-8:

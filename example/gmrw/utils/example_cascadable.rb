# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/utils/cascadable'

class C
  include GMRW::Utils::Cascadable

  def initialize(&block)
    cascade(&block)
  end

  def on
    @status = :on
  end

  def off
    @status = :off
  end

  attr_reader :status
end

c0 = C.new
p c0.status        # => nil

c1 = C.new { on }
p c1.status        # => :on

c2 = C.new {|c| c.off }
p c2.status        # => :off

p c0.evaluate { on }  # => :on
p c0.cascade  { on }  # => #<C:0x000000........ @status=:on> (self)

p c0.evaluate {|c| c.on }  # => :on
p c0.cascade  {|c| c.on }  # => #<C:0x000000........ @status=:on> (self)

# vim:set ts=2 sw=2 et fenc=utf-8:

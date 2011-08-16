# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/object'
require 'gmrw/utils/constants'

class GMRW::Utils::Command < Array
  def initialize(*a, &block)
    super(*a, &nil)
    cascade(&block)
  end

  def call(*a, &b)
    each {|cmd| cmd.call(*a, &b) }
  end

  alias [] call

  def to_proc
    method(:call).to_proc
  end

  def add(&block)
    push(block)
  end

  def +(other)
    self.class.new.replace(to_a + Array(other))
  end
end

=begin
if __FILE__ == $0
  #command = GMRW::Utils::Command.new
  #command.add {|s| puts "hello," + s}

  command = GMRW::Utils::Command.new do |f|
    f.add {|s| puts "Hello," + s }
  end

  command.add { puts "3" }
  command.add { puts "2" }
  command.add { puts "1" }

#  command.call("world")

  command2 = command + [proc { puts "0!!" }, proc { puts "A" }]
  command2.call("world")
end
=end

# vim:set ts=2 sw=2 et fenc=UTF-8:

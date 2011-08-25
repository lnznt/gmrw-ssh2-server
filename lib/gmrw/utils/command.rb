# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/utils/cascadable'

module GMRW; module Utils; class Command < Array
  include GMRW::Utils::Cascadable

  def initialize(*a, &block)
    super(&nil)
    cascade(&block)
  end

  def call(*a, &b)
    each {|cmd| cmd.call(*a, &b) }
  end

  def [](*a, &b)
    call(*a, &b)
  end

  def to_proc
    method(:call).to_proc
  end

  def add(&block)
    push(block)
  end

  def +(other)
    self.class.new.replace(to_a + Array(other))
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

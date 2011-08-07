#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

module GMRW           #:nodoc:
  module Alternative  #:nodoc:
    extend self
    private
    def compatibility(to, &block) #:nodoc:
      mod = Module.new(&block)

      dups = to.instance_methods & mod.instance_methods
      dups.each {|name| mod.send(:undef_method, name) }

      to.send(:include, mod)
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

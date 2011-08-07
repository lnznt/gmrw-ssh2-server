#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

module GMRW
  module Extension
    extend self
    private
    def mixin(to, &block) #:nodoc:
      mod = Module.new(&block)

      dups = to.instance_methods & mod.instance_methods
      dups.empty? or raise "#{to}: duplicate methods #{dups} in #{mod}"

      to.send(:include, mod)
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

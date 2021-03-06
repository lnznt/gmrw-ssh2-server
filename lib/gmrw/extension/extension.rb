# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

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

    def compatibility(to, &block) #:nodoc:
      mod = Module.new(&block)

      dups = to.instance_methods & mod.instance_methods
      dups.each {|name| mod.send(:undef_method, name) }

      to.send(:include, mod)
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

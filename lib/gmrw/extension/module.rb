#!/usr/bin/env ruby
# -*- coding :UTF-8 -*-

require 'gmrw/extension/extension'

module GMRW::Extension
  mixin Module do
    def def_accessor(mode, name, default='')
      no_arg      = "def #{name}"
      va_arg      = "def #{name}(*args, &block)"
      set_default = "instance_variable_defined?(:@#{name})" +
                      " or (@#{name} = (#{default}))"
      ret_val     = "@#{name}"
      set_val     = "@#{name} = args.empty? ? (block || @#{name}) : args.first"
      def_writer  = "attr_writer :#{name}"

      module_eval case mode
        when :ro  ; [no_arg, set_default, ret_val, "end"]
        when :rw  ; [va_arg, set_default, set_val, "end"]
        when :roa ; [no_arg, set_default, ret_val, "end", def_writer]
        when :rwa ; [va_arg, set_default, set_val, "end", def_writer]
      end * ';'
    end

    def property_ro(name, default='')
      def_accessor:ro, name, default
    end

    def property_wr(name, default='')
      def_accessor:wr, name, default
    end

    def property_roa(name, default='')
      def_accessor:roa, name, default
    end

    def property_rwa(name, default='')
      def_accessor:rwa, name, default
    end

    alias property property_rwa
  end
end

if __FILE__ == $0
  class C
    property :foo, 10
  end

  c = C.new
  p c.foo
  p c.foo = 20
  p c.foo
  p c.foo
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

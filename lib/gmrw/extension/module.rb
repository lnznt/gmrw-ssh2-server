# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'

module GMRW::Extension
  mixin Module do
    def abstract_method(method_name)
      define_method(method_name) { raise NotImplementedError, method_name.to_s }
    end

    private
    def self.define_property(method_name, keys) #:nodoc:
      define_method(method_name) do |name, *args|
        default = args.empty? ? '' : args.first

        statements = {
          :no_arg   => "def #{name}",
          :va_arg   => "def #{name}(*args, &block)",
          :default  => "instance_variable_defined?(:@#{name})" +
                          " or (@#{name} = (#{default}))",
          :return   => "@#{name}",
          :set_val  => "@#{name} = args.empty? ? (block || @#{name}) : args.first",
          :end      => "end",
          :attr_w   => "attr_writer :#{name}",
        }

        module_eval(keys.map{|key| statements[key]} * ';')
      end
    end

    public
    define_property :property_ro,  [:no_arg, :default, :return,  :end]
    define_property :property_rw,  [:va_arg, :default, :set_val, :end]
    define_property :property_roa, [:no_arg, :default, :return,  :end, :attr_w]
    define_property :property_rwa, [:va_arg, :default, :set_val, :end, :attr_w]

    alias property property_rwa
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

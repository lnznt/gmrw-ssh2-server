# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'

module GMRW::Extension
  mixin Module do
    def def_initialize(name)
      module_eval "property :#{name} ; alias initialize #{name}="
    end

    private
    def self.define_property(method_name, keys) #:nodoc:
      define_method(method_name) do |name, *args|
        default = args.empty? ? '' : args[0]

        statements = {
          :no_arg   => "def #{name}",
          :va_arg   => "def #{name}(*args, &block)",
          :default  => "instance_variable_defined?(:@#{name})" +
                          " or (@#{name} = (#{default}))",
          :nvl      => "!@#{name}.nil? or (@#{name} = (#{default}))",
          :return   => "@#{name}",
          :set_val  => "@#{name} = args.empty? ? (block || @#{name}) : args[0]",
          :end      => "end",
          :attr_w   => "attr_writer :#{name}",
        }

        module_eval(keys.map{|key| statements[key]} * ';')
      end
    end

    public
    define_property :property_ro,   [:no_arg, :default,       :return,  :end]
    define_property :property_rov,  [:no_arg, :default, :nvl, :return,  :end]
    define_property :property_rw,   [:va_arg, :default,       :set_val, :end]
    define_property :property_rwv,  [:va_arg, :default, :nvl, :set_val, :end]
    define_property :property_roa,  [:no_arg, :default,       :return,  :end, :attr_w]
    define_property :property_rova, [:no_arg, :default, :nvl, :return,  :end, :attr_w]
    define_property :property_rwa,  [:va_arg, :default,       :set_val, :end, :attr_w]
    define_property :property_rwva, [:va_arg, :default, :nvl, :set_val, :end, :attr_w]

    alias property property_rwa
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'
require 'gmrw/extension/module'

module GMRW::Extension
  mixin Object do
    def is
      @is ||= Class.new {
        def boolean? ; this == true || this == false                          ; end
        def byte?    ; this.kind_of?(Integer) && (0...(1<< 8)).include?(this) ; end
        def uint32?  ; this.kind_of?(Integer) && (0...(1<<32)).include?(this) ; end
        def uint64?  ; this.kind_of?(Integer) && (0...(1<<64)).include?(this) ; end
        def integer? ; this.kind_of?(Integer)                                 ; end
        def string?  ; this.kind_of?(String)                                  ; end
        def array?   ; this.kind_of?(Array)                                   ; end
        def hash?    ; this.kind_of?(Hash)                                    ; end
        def symbol?  ; this.kind_of?(Symbol)                                  ; end
        def proc?    ; this.kind_of?(Proc)                                    ; end

        private
        attr_accessor :this ; alias initialize this=
      }.new(self)
    end

    private
    property_ro :null, 'Class.new{ def method_missing(*) ; end }.new'
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/attribute'

class GMRW::Extension::Attribute
  module Is
    def boolean?            ; (this == true || this == false) rescue false ; end

    def array?(*a, &b)      ; eq?(Array,       *a) { this.all?(&b) } ; end
    def bignum?(*a, &b)     ; eq?(Bignum,      nil, *a, &b)          ; end
    def class?(*a, &b)      ; eq?(Class,       nil, *a, &b)          ; end
    def comparable?(*a, &b) ; eq?(Comparable,  nil, *a, &b)          ; end
    def complex?(*a, &b)    ; eq?(Complex,     nil, *a, &b)          ; end
    def dir?(*a, &b)        ; eq?(Dir,         nil, *a, &b)          ; end
    def enumerable?(*a, &b) ; eq?(Enumerable,  *a) { this.all?(&b) } ; end
    def errno?(*a, &b)      ; eq?(Errno,       nil, *a, &b)          ; end
    def exception?(*a, &b)  ; eq?(Exception,   nil, *a, &b)          ; end
    def file?(*a, &b)       ; eq?(File,        nil, *a, &b)          ; end
    def fixnum?(*a, &b)     ; eq?(Fixnum,      nil, *a, &b)          ; end
    def float?(*a, &b)      ; eq?(Float,       nil, *a, &b)          ; end
    def hash?(*a, &b)       ; eq?(Hash,        *a) { this.all?(&b) } ; end
    def io?(*a, &b)         ; eq?(IO,          nil, *a, &b)          ; end
    def integer?(*a, &b)    ; eq?(Integer,     nil, *a, &b)          ; end
    def method?(*a, &b)     ; eq?(Method,      nil, *a, &b)          ; end
    def numeric?(*a, &b)    ; eq?(Numeric,     nil, *a, &b)          ; end
    def proc?(*a, &b)       ; eq?(Proc,        nil, *a, &b)          ; end
    def range?(*a, &b)      ; eq?(Range,       nil, *a, &b)          ; end
    def regexp?(*a, &b)     ; eq?(Regexp,      nil, *a, &b)          ; end
    def string?(*a, &b)     ; eq?(String,      *a,      &b)          ; end
    def struct?(*a, &b)     ; eq?(Struct,      nil, *a, &b)          ; end
    def symbol?(*a, &b)     ; eq?(Symbol,      nil, *a, &b)          ; end
    def thread?(*a, &b)     ; eq?(Thread,      nil, *a, &b)          ; end
    def time?(*a, &b)       ; eq?(Time,        nil, *a, &b)          ; end

    def uint8?   ; integer?(0...(1<< 8)) ; end
    def uint16?  ; integer?(0...(1<<16)) ; end
    def uint32?  ; integer?(0...(1<<32)) ; end
    def uint64?  ; integer?(0...(1<<64)) ; end

    alias octet? uint8?
    alias byte?  uint8?

    private
    def eq?(clazz, len=nil, *tests, &block)
      this.kind_of?(clazz)          &&
      (!len || this.length == len)  &&
      tests.all? {|t| t === this }  &&
      (!block || block[this])
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

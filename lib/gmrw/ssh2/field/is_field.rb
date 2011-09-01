# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#
require 'openssl'
require 'gmrw/extension/all'

module GMRW; module SSH2; module Field
  class IsField
    private
    def_initialize :this

    def this_is?(*tests, &all_test)
      tests.all? {|t| t === this } && (!all_test || this.all?(&all_test))
    end

    public
    def boolean?  ; this == true || this == false                      ; end
    def byte?     ; this_is?(Integer, 0...(1<< 8))                     ; end
    def uint32?   ; this_is?(Integer, 0...(1<<32))                     ; end
    def uint64?   ; this_is?(Integer, 0...(1<<64))                     ; end
    def mpint?    ; this_is?(OpenSSL::BN)                              ; end
    def string?   ; this_is?(String)                                   ; end
    def namelist? ; this_is?(Array){|s| s.is.name?}                    ; end
    def bytes?    ; this_is?(Array){|b| b.is.byte?} && this.length > 0 ; end

    def name?
      !!(this.kind_of?(String)           &&
         this =~ /\A[[:graph:]]{1,64}\z/ &&
         this !~ /,/                     &&
         this =~ /\A[^@]+(@[^@]+)?\z/    )
    end

    def type?(type)
      case type
        when :boolean  ; boolean?
        when :byte     ; byte?
        when :uint32   ; uint32?
        when :uint64   ; uint64?
        when :mpint    ; mpint?
        when :string   ; string?
        when :name     ; name?
        when :namelist ; namelist?
        when :bytes    ; bytes?
        when Integer   ; bytes? && this.length == type
      end or false
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

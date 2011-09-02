# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#
require 'openssl'
require 'gmrw/extension/all'

module GMRW; module SSH2; module Field
  module IsType
    private
    def name?(s)
      !!(s.is.string?                 &&
         s =~ /\A[[:graph:]]{1,64}\z/ &&
         s !~ /,/                     &&
         s =~ /\A[^@]+(@[^@]+)?\z/    )
    end

    public
    def boolean?  ; this.is.boolean?                                                 ; end
    def byte?     ; this.is.byte?                                                    ; end
    def uint32?   ; this.is.uint32?                                                  ; end
    def uint64?   ; this.is.uint64?                                                  ; end
    def string?   ; this.is.string?                                                  ; end
    def mpint?    ; this.kind_of?(OpenSSL::BN)                                       ; end
    def namelist? ; this.is.array? && this.all? {|s| name?(s) }                      ; end
    def bytes?    ; this.is.array? && this.all? {|b| b.is.byte? } && this.length > 0 ; end

    def type?(type)
      case type
        when :boolean  ; boolean?
        when :byte     ; byte?
        when :uint32   ; uint32?
        when :uint64   ; uint64?
        when :mpint    ; mpint?
        when :string   ; string?
        when :namelist ; namelist?
        when Integer   ; bytes? && this.length == type
      end or false
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

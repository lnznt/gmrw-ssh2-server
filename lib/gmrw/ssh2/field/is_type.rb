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
    def type?(type)
      case n=type
        when :boolean  ; this.is.boolean?
        when :byte     ; this.is.byte?
        when :uint32   ; this.is.uint32?
        when :uint64   ; this.is.uint64?
        when :mpint    ; this.kind_of?(OpenSSL::BN)
        when :string   ; this.is.string?
        when :namelist ; this.is.array?    {|s| name?(s)   }
        when Integer   ; this.is.array?(n) {|b| b.is.byte? } && n > 0
      end or false
    end

    private
    def name?(s)
      !!(s.is.string?                 &&
         s =~ /\A[[:graph:]]{1,64}\z/ &&
         s !~ /,/                     &&
         s =~ /\A[^@]+(@[^@]+)?\z/    )
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#
require 'openssl'
require 'gmrw/extension/all'

module GMRW; module SSH2; module Field
  include GMRW

  class SSHField
    private
    def name?(s)
      !!(s.is.string?                 &&
         s =~ /\A[[:graph:]]{1,64}\z/ &&
         s !~ /,/                     &&
         s =~ /\A[^@]+(@[^@]+)?\z/    )
    end

    public
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

    def default(type)
      case n=type
        when :boolean  ; false
        when :byte     ; 0
        when :uint32   ; 0
        when :uint64   ; 0
        when :mpint    ; 0.to.bn
        when :string   ; ""
        when :namelist ; []
        when Integer   ; n > 0 ? ([0] * n) : nil
      end
    end

    def pack
      this.map {|ftype, val| val.ssh.encode(ftype) }.join
    end

    def unpack(ftypes)
      ftypes.reduce([[], s=this]) {|result, ftype|
        v, s = s.ssh.decode(ftype) ; [result[0] << v, s]
      }.flatten(1)
    end

    def encode(type)
      case type
        when :boolean  ; (this ? 1 : 0).pack.byte
        when :byte     ; this.pack.byte
        when :uint32   ; this.pack.uint32
        when :uint64   ; this.pack.uint64
        when :mpint    ; this.to_i.pack.bin.to.packet
        when :string   ; this.bin.to.packet
        when :namelist ; this.join(",").bin.to.packet
        when Integer   ; this.pack("C*")
      end
    end

    def decode(type)
      s, rem = sep(type)
      s && rem or raise "cannot separate: #{type}: #{this}"

      [s.ssh.dec(type), rem]
    end

    private
    def_initialize :this

    def field_size(type)
      case n=type
        when :boolean  ; 1
        when :byte     ; 1
        when :uint32   ; 4
        when :uint64   ; 8
        when :mpint    ; nil
        when :string   ; nil
        when :namelist ; nil
        when Integer   ; n
        else ; raise(TypeError, "#{type}")
      end
    end

    def sep(type, s=this)
      len = field_size(type)
      len ? (s / len) : sep(*s.unpack("Na*"))
    end

    protected
    def dec(type)
      case type
        when :boolean  ; this.to.byte != 0
        when :byte     ; this.to.byte
        when :uint32   ; this.to.uint32
        when :uint64   ; this.to.uint64
        when :string   ; this
        when :namelist ; this.split(",")
        when Integer   ; this.to.bytes
        when :mpint    ; this.to.mpi.to.bn
      end
    end
  end
end;end;end

# vim:set ts=2 sw=2 et fenc=utf-8:

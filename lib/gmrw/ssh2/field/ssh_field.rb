# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#
require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/ssh2/field/is_type'

module GMRW; module SSH2; module Field
  include GMRW

  class SSHField
    include IsType

    def encode(type)
      case type
        when :boolean  ; (this ? 1 : 0).pack.byte
        when :byte     ; this.pack.byte
        when :uint32   ; this.pack.uint32
        when :uint64   ; this.pack.uint64
        when :mpint    ; this.to_i.pack.bin.to_packet
        when :string   ; this.bin.to_packet
        when :namelist ; this.join(",").bin.to_packet
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

    def sep(type, s=this)
      len = SSH2::Field.field_size(type)
      len ? (s / len) : sep(*s.unpack("Na*"))
    end

    protected
    def dec(type)
      case type
        when :boolean  ; this.unpack("C")[0] != 0
        when :byte     ; this.unpack("C")[0]
        when :uint32   ; this.unpack("N")[0]
        when :uint64   ; this.unpack("NN").reduce {|n,m| n << 32 | m }
        when :string   ; this
        when :namelist ; this.split(",")
        when Integer   ; this.unpack("C*")
        when :mpint    ; OpenSSL::BN.new(this.pack_mpi.to_s)
      end
    end
  end
end;end;end

# vim:set ts=2 sw=2 et fenc=utf-8:

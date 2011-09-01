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
    def_initialize :this

    public
    def encode(type)
      case type
        when :boolean  ; [this ? 1 : 0].pack("C")
        when :byte     ; [this].pack("C")
        when :uint32   ; [this].pack("N")
        when :uint64   ; [this.bit[63..32], this.bit[31..0]].pack("NN")
        when :mpint    ; this.to_i.bit.div(8).pack("C*").to_packet(4)
        when :string   ; this.to_packet(4)
        when :namelist ; this.join(",").to_packet(4)
        when Integer   ; this.pack("C*")
      end
    end

    private
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
        when :mpint
          n = this.pack_mpi
          OpenSSL::BN.new(n.abs.to_s) * n.signum
      end
    end

    public
    def decode(type)
      s, rem = sep(type)
      s && rem or raise "cannot separate: #{type}: #{this}"

      [s.ssh.dec(type), rem]
    end
  end
end;end;end

# vim:set ts=2 sw=2 et fenc=utf-8:

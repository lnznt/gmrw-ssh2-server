# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#
require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/extension/attribute'

module GMRW; module SSH2; module Message
  module DataType
    private
    def name?(s)
      !!(s.is.string?                 &&
         s =~ /\A[[:graph:]]{1,64}\z/ &&
         s !~ /,/                     &&
         s =~ /\A[^@]+(@[^@]+)?\z/    )
    end

    def spec(type)
      type, n = (type.is.integer? && type.positive?) ? [:bytes, type] : [type, 0]

      {
        :boolean  => {  :default  => false,
                        :is_type  => this.is.boolean?,
                        :encode   => proc { (this ? 1 : 0).pack.byte },
                        :separate => proc { this / 1 },
                        :decode   => proc {|s| s.to.byte != 0 },
        },
        :byte     => {  :default  => 0,
                        :is_type  => this.is.byte?,
                        :encode   => proc { this.pack.byte },
                        :separate => proc { this / 1 },
                        :decode   => proc {|s| s.to.byte },
        },
        :uint32   => {  :default  => 0,
                        :is_type  => this.is.uint32?,
                        :encode   => proc { this.pack.uint32 },
                        :separate => proc { this / 4 },
                        :decode   => proc {|s| s.to.uint32 },
        },
        :uint64   => {  :default  => 0,
                        :is_type  => this.is.uint64?,
                        :encode   => proc { this.pack.uint64 },
                        :separate => proc { this / 8 },
                        :decode   => proc {|s| s.to.uint64 },
        },
        :mpint    => {  :default  => 0,
                        :is_type  => this.kind_of?(OpenSSL::BN),
                        :encode   => proc { this.to_i.pack.bin.to.packet },
                        :separate => proc { this[4..-1] / this.to.uint32 },
                        :decode   => proc {|s| s.to.mpi.to.bn },
        },
        :string   => {  :default  => "",
                        :is_type  => this.is.string?,
                        :encode   => proc { this.bin.to.packet },
                        :separate => proc { this[4..-1] / this.to.uint32 },
                        :decode   => proc {|s| s },
        },
        :namelist => {  :default  => [],
                        :is_type  => this.is.array? {|s| name?(s) },
                        :encode   => proc { this.join(",").bin.to.packet },
                        :separate => proc { this[4..-1] / this.to.uint32 },
                        :decode   => proc {|s| s.split(",") },
        },
        :bytes    => {  :default  => ssh.random(n).to.bytes,
                        :is_type  => this.is.array?(n) {|b| b.is.byte? },
                        :encode   => proc { this.pack("C*") },
                        :separate => proc { this / n },
                        :decode   => proc {|s| s.to.bytes },
        },
      }[type] || {}
    end

    public
    def type?(type)
      !!spec(type)[:is_type]
    end

    def default(type)
      spec(type)[:default]
    end

    def encode(type)
      spec(type)[:encode].call
    end

    def decode(type)
      s, rem = spec(type)[:separate].call
      [spec(type)[:decode][s], rem]
    end

    def pack
      this.map {|ftype, val| val.ssh.encode(ftype) }.join
    end

    def unpack(ftypes)
      ftypes.reduce([[], s=this]) {|result, ftype|
        v, s = s.ssh.decode(ftype) ; [result[0] << v, s]
      }.flatten(1)
    end

    def random(n)
      OpenSSL::Random.random_bytes(n)
    end
  end
end; end; end

module GMRW::Extension
  mixin Object do
    attribute :ssh, GMRW::SSH2::Message::DataType
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

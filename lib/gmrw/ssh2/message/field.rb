# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#
require 'openssl'
require 'gmrw/extension/all'

module GMRW; module SSH2; module Message; module Field
  extend self
  def default(ftype)
    case n=ftype
      when :boolean              ; false
      when :byte,:uint32,:uint64 ; 0
      when :mpint                ; OpenSSL::BN.new(0.to_s)
      when :string               ; ""
      when :namelist             ; []
      when Integer               ; [0] * n 
    end
  end

  def validate(ftype, x)
    # see RFC4250 (4.6.1) for details
    is_name = proc {|s| s.kind_of?(String)           &&
                        s =~ /\A[[:graph:]]{1,64}\z/ &&
                        s !~ /,/                     &&
                        s =~ /\A[^@]+(@[^@]+)?\z/     }

    is_byte = proc {|b| validate(:byte, b) }

    case n=ftype
      when :boolean  ; x == true || x == false
      when :byte     ; x.kind_of?(Integer) && (0...(1<< 8)).include?(x)
      when :uint32   ; x.kind_of?(Integer) && (0...(1<<32)).include?(x)
      when :uint64   ; x.kind_of?(Integer) && (0...(1<<64)).include?(x)
      when :mpint    ; x.kind_of?(OpenSSL::BN)
      when :string   ; x.kind_of?(String)
      when :namelist ; x.kind_of?(Array) && x.all? {|s| is_name[s] }
      when Integer   ; x.kind_of?(Array) && x.all? {|b| is_byte[b] } && x.count == n
    end
  end

  def decode(ftype, str)
    case n=ftype
      when :byte     ; b, s  = str.unpack("Ca*")    ; b && [b,       s]
      when :uint32   ; n, s  = str.unpack("Na*")    ; n && [n,       s]
      when :uint64   ; n,m,s = str.unpack("NNa*")   ; m && [n<<32|m, s]
      when :boolean  ; b, s  = decode(:byte, str)   ; b && [b != 0,  s] 
      when :string   ; n, s  = decode(:uint32, str) ; s/n if n && s.length >= n
      when :mpint    ; b, s  = decode(:string, str) ; b && [b2n(b),         s]
      when :namelist ; l, s  = decode(:string, str) ; l && [l.split(","),   s]
      when Integer   ; ((b,s = str / n) and (b && s && [b.unpack("C*"), s]))
    end
  end

  def encode(ftype, val)
    case ftype
      when :byte     ; [val                    ].pack("C")
      when :uint32   ; [val                    ].pack("N")
      when :uint64   ; [val>>32, val&0xffffffff].pack("NN")
      when :string   ; [val.length, val        ].pack("Na*")
      when :mpint    ; encode(:string, n2b(val.to_i).pack("C*"))
      when :namelist ; encode(:string, val.join(","))
      when :boolean  ; encode(:byte,   val ? 1 : 0)
      when Integer   ; val.pack("C*")
    end
  end

  def pack(*fields)
    fields.map {|ftype, val| encode(ftype, val) }.join
  end

  def unpack(s, ftypes)
    ftypes.reduce([[], s]) do |result, ftype|
      v, s = decode(ftype, s) ; [result[0] << v, s] 
    end
  end

  private
  MSB = 7

  def b2n(b)
    b = b.unpack("C*")

    zero     = b.empty?
    negative = !zero && (b[0][MSB] == 1)

    b.map! {|n| ~n & 0xff }   if negative
    n = b.inject(0) {|sum, n| sum << 8 | n }
    n = -(n + 1)              if negative

    OpenSSL::BN.new(n.to_s)
  end

  def n2b(n)
    positive = n > 0
    negative = n < 0

    n = n.abs - 1 if negative
    b = [] ; (b.unshift(n & 0xff) ; n >>= 8) while n > 0
    b.map! {|n| ~n & 0xff} if negative

    b = [0xff] if negative && b.empty?

    b.unshift(0x00) if positive && (b[0][MSB] == 1)
    b.unshift(0xff) if negative && (b[0][MSB] == 0)

    b
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'

module GMRW; module SSH2; module Message; module Fields
  extend self
  def bytes?(ftype)
    ftype.kind_of?(Integer) && (ftype > 0)
  end

  def default(ftype)
    case ftype
      when :boolean                     ; false
      when :byte,:uint32,:uint64,:mpint ; 0
      when :string                      ; ""
      when :namelist                    ; []
      else; bytes?(ftype)               ? Array.new(ftype, 0)
                                        : nil
    end
  end

  def validate(ftype, x)
    # RFC 4250 (4.6.1) (意訳)
    #   名前は、表示可能な US-ASCII (21h-7eh) で 64 バイト以下。
    #   カンマ(,) とアットマーク(@) を含んではならない。
    #   ただし、ローカル拡張の名前に関しては以下のようにしてよい。
    #
    #     名前 @ ローカルドメイン名 (「@」は区切りに使われる 1 つのみ)
    #
    is_name = proc {|s| s.kind_of?(String)           &&
                        s =~ /\A[[:graph:]]{1,64}\z/ &&
                        s !~ /,/                     &&
                        s =~ /\A[^@]+(@[^@]+)?\z/     }

    check = proc {|x, *tests| tests.all? {|t| t === x }}

    case ftype
      when :boolean       ; x == true || x == false
      when :byte          ; check[x, Integer, 0...(1<< 8)]
      when :uint32        ; check[x, Integer, 0...(1<<32)]
      when :uint64        ; check[x, Integer, 0...(1<<64)]
      when :mpint         ; check[x, Integer]
      when :string        ; check[x, String ]
      when :namelist      ; check[x, Array] && x.all? {|s| is_name[s] }
      else; bytes?(ftype) ? check[x, Array] &&
                                x.all? {|b| validate(:byte, b) } &&
                                x.length == ftype
                          : false
    end
  end

  def decode(ftype, str)
    case ftype
      when :byte          ; b, s  = str.unpack("Ca*")    ; b && [b,       s]
      when :uint32        ; n, s  = str.unpack("Na*")    ; n && [n,       s]
      when :uint64        ; n,m,s = str.unpack("NNa*")   ; m && [n<<32|m, s]
      when :boolean       ; b, s  = decode(:byte, str)   ; b && [b != 0,  s] 

      when :string        ; n, s  = decode(:uint32, str) ; s/n if n && s.length >= n
      when :mpint         ; b, s  = decode(:string, str) ; b && [b2n(b.unpack("C*")), s]
      when :namelist      ; l, s  = decode(:string, str) ; l && [l.split(","),        s]

      else; bytes?(ftype) ? ((b,s = str / ftype) and (b && s && [b.unpack("C*"), s])) : nil
    end
  end

  def encode(ftype, val)
    case ftype
      when :byte          ; [val                    ].pack("C")
      when :uint32        ; [val                    ].pack("N")
      when :uint64        ; [val>>32, val&0xffffffff].pack("NN")
      when :string        ; [val.length, val        ].pack("Na*")

      when :boolean       ; encode(:byte,   val ? 1 : 0        )
      when :mpint         ; encode(:string, n2b(val).pack("C*"))
      when :namelist      ; encode(:string, val.join(",")      )

      else; bytes?(ftype) ? val.pack("C*") : nil
    end
  end

  private
  MSB = 7

  def b2n(b)
    zero     = b.empty?
    negative = !zero && (b[0][MSB] == 1)

    b.map! {|n| ~n & 0xff }   if negative
    n = b.inject(0) {|sum, n| sum << 8 | n }
    n = -(n + 1)              if negative

    n
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

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/string'
require 'gmrw/utils/filter'
require 'gmrw/ssh2/message/constants'

module GMRW::SSH2::Message::Fields
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

  def validate(ftype, val)
    is_boolean  = GMRW::Utils::Filter.new.add {|x| x == true || x == false }
    is_integer  = GMRW::Utils::Filter.new.add {|x| x.kind_of?(Integer) }
    is_string   = GMRW::Utils::Filter.new.add {|x| x.kind_of?(String ) }
    is_array    = GMRW::Utils::Filter.new.add {|x| x.kind_of?(Array)}

    is_byte     = is_integer + proc {|n| (0...(1<< 8)).include?(n) }
    is_uint32   = is_integer + proc {|n| (0...(1<<32)).include?(n) }
    is_uint64   = is_integer + proc {|n| (0...(1<<64)).include?(n) }
    is_mpint    = is_integer

    is_bytes    = is_array  + proc {|a| a.all? {|b| is_byte[b] } }

    is_name     = is_string + proc {|s| !s.empty? && s !~ /,/ }
    is_namelist = is_array  + proc {|a| a.all? {|s| is_name[s] } }

    case ftype
      when :boolean       ; is_boolean  [val]
      when :byte          ; is_byte     [val]
      when :uint32        ; is_uint32   [val]
      when :uint64        ; is_uint64   [val]
      when :mpint         ; is_mpint    [val]
      when :string        ; is_string   [val]
      when :namelist      ; is_namelist [val]
      else; bytes?(ftype) ? is_bytes    [val] && (val.length == ftype)
                          : false
    end
  end

  def validate!(ftype, val)
    validate(ftype, val) or raise TypeError, "<#{ftype}>:'#{val}'"
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
end

# vim:set ts=2 sw=2 et fenc=utf-8:

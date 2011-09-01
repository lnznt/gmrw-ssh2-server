# -*- coding: ascii -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'test/unit'
require 'openssl'
require 'gmrw/ssh2/field'

class TestField < Test::Unit::TestCase
  include GMRW::SSH2

  def try_assert_equal(tests)
    tests.each_with_index do |test, i|
      actual, expected = test.first
      assert_equal(expected, actual, "case##{i}")
    end
  end

  def setup
    @bn0      = OpenSSL::BN.new(0.to_s)
    @bn1      = OpenSSL::BN.new(1.to_s)
    @bn1234h  = OpenSSL::BN.new(0x1234.to_s)
    @bn8000h  = OpenSSL::BN.new(0x8000.to_s)
    @bn_1234h = OpenSSL::BN.new((-0x1234).to_s)
    @bn_beefh = OpenSSL::BN.new((-0xbeef).to_s)
  end

  def test_boolean?
    try_assert_equal [
      { true.is.boolean?              =>  true   },
      { false.is.boolean?             =>  true   },

      { nil.is.boolean?               =>  false  },
      { 0.is.boolean?                 =>  false  },
      { 0.0.is.boolean?               =>  false  },
      { "".is.boolean?                =>  false  },
      { " ".is.boolean?               =>  false  },
      { "0".is.boolean?               =>  false  },
      { [].is.boolean?                =>  false  },
      { [0].is.boolean?               =>  false  },
      { {}.is.boolean?                =>  false  },
      { :true.is.boolean?             =>  false  },
    ]
  end

  def test_byte?
    try_assert_equal [
      { 0.is.byte?                    =>  true   },
      { 1.is.byte?                    =>  true   },
      { 255.is.byte?                  =>  true   },

      { -1.is.byte?                   =>  false  },
      { 256.is.byte?                  =>  false  },
      { true.is.byte?                 =>  false  },
      { false.is.byte?                =>  false  },
      { nil.is.byte?                  =>  false  },
      { 0.0.is.byte?                  =>  false  },
      { "1".is.byte?                  =>  false  },
      { [1].is.byte?                  =>  false  },
      { {}.is.byte?                   =>  false  },
      { :true.is.byte?                =>  false  },
    ]
  end

  def test_uint32?
    try_assert_equal [
      { 0.is.uint32?                  =>  true   },
      { 1.is.uint32?                  =>  true   },
      { ((1<<32)-1).is.uint32?        =>  true   },

      { -1.is.uint32?                 =>  false  },
      { (1<<32).is.uint32?            =>  false  },
      { true.is.uint32?               =>  false  },
      { false.is.uint32?              =>  false  },
      { nil.is.uint32?                =>  false  },
      { 0.0.is.uint32?                =>  false  },
      { "1".is.uint32?                =>  false  },
      { [1].is.uint32?                =>  false  },
      { {}.is.uint32?                 =>  false  },
      { :true.is.uint32?              =>  false  },
    ]
  end

  def test_uint64?
    try_assert_equal [
      { 0.is.uint64?                  =>  true   },
      { 1.is.uint64?                  =>  true   },
      { ((1<<64)-1).is.uint64?        =>  true   },

      { -1.is.uint64?                 =>  false  },
      { (1<<64).is.uint64?            =>  false  },
      { true.is.uint64?               =>  false  },
      { false.is.uint64?              =>  false  },
      { nil.is.uint64?                =>  false  },
      { 0.0.is.uint64?                =>  false  },
      { "1".is.uint64?                =>  false  },
      { [1].is.uint64?                =>  false  },
      { {}.is.uint64?                 =>  false  },
      { :true.is.uint64?              =>  false  },
    ]
  end

  def test_mpint?
    try_assert_equal [
      { @bn0.is.mpint?                =>  true   },
      { @bn1.is.mpint?                =>  true   },
      { @bn1234h.is.mpint?            =>  true   },
      { @bn8000h.is.mpint?            =>  true   },
      { @bn_1234h.is.mpint?           =>  true   },
      { @bn_beefh.is.mpint?           =>  true   },

      { 0.is.mpint?                   =>  false  },
      { 1.is.mpint?                   =>  false  },
      { -1.is.mpint?                  =>  false  },
      { 100.is.mpint?                 =>  false  },
      { true.is.mpint?                =>  false  },
      { false.is.mpint?               =>  false  },
      { nil.is.mpint?                 =>  false  },
      { 0.0.is.mpint?                 =>  false  },
      { "1".is.mpint?                 =>  false  },
      { [1].is.mpint?                 =>  false  },
      { {}.is.mpint?                  =>  false  },
      { :true.is.mpint?               =>  false  },
    ]
  end

  def test_string?
    try_assert_equal [
      { "".is.string?                =>  true  },
      { "a".is.string?               =>  true  },
      { "hello".is.string?           =>  true  },
      { "a,b".is.string?             =>  true  },
      { ",ab".is.string?             =>  true  },
      { "ab,".is.string?             =>  true  },
      { "a,,b".is.string?            =>  true  },
      { ",a,b".is.string?            =>  true  },
      { "a,b,".is.string?            =>  true  },
      { "@a".is.string?              =>  true  },
      { "a@".is.string?              =>  true  },
      { "a@b".is.string?             =>  true  },
      { "@a@b".is.string?            =>  true  },
      { "a@b@".is.string?            =>  true  },
      { "a@b@c".is.string?           =>  true  },
      { "a@@c".is.string?            =>  true  },
      { "a b".is.string?             =>  true  },
      { " ab".is.string?             =>  true  },
      { "ab ".is.string?             =>  true  },
      { "a b".is.string?             =>  true  },
      { ("a" * 65).is.string?        =>  true  },
      { "\n".is.string?              =>  true  },
      { "\r\n".is.string?            =>  true  },
      { "a\r\n".is.string?           =>  true  },
      { "a\n".is.string?             =>  true  },
      { " a\tb".is.string?           =>  true  },
      { "a\x7fb".is.string?          =>  true  },
      { "\x01abc".is.string?         =>  true  },

      { 1.is.string?                 =>  false  },
      { :a.is.string?                =>  false  },
      { [].is.string?                =>  false  },
      { true.is.string?              =>  false  },
      { nil.is.string?               =>  false  },
    ]
  end

  def test_name?
    try_assert_equal [
      { "a".is.name?                 =>  true  },
      { "hello".is.name?             =>  true  },
      { "a@b".is.name?               =>  true  },
      { ("a" * 64).is.name?          =>  true  },

      { "".is.name?                  =>  false  },
      { "a,b".is.name?               =>  false  },
      { ",ab".is.name?               =>  false  },
      { "ab,".is.name?               =>  false  },
      { "a,,b".is.name?              =>  false  },
      { ",a,b".is.name?              =>  false  },
      { "a,b,".is.name?              =>  false  },
      { "@a".is.name?                =>  false  },
      { "a@".is.name?                =>  false  },
      { "@a@b".is.name?              =>  false  },
      { "a@b@".is.name?              =>  false  },
      { "a@b@c".is.name?             =>  false  },
      { "a@@c".is.name?              =>  false  },
      { "a b".is.name?               =>  false  },
      { " ab".is.name?               =>  false  },
      { "ab ".is.name?               =>  false  },
      { "a b".is.name?               =>  false  },
      { ("a" * 65).is.name?          =>  false  },
      { "\n".is.name?                =>  false  },
      { "\r\n".is.name?              =>  false  },
      { "a\r\n".is.name?             =>  false  },
      { "a\n".is.name?               =>  false  },
      { " a\tb".is.name?             =>  false  },
      { "a\x7fb".is.name?            =>  false  },
      { "\x01abc".is.name?           =>  false  },

      { 1.is.name?                   =>  false  },
      { :a.is.name?                  =>  false  },
      { [].is.name?                  =>  false  },
      { true.is.name?                =>  false  },
      { nil.is.name?                 =>  false  },
    ]
  end

  def test_namelist?
    try_assert_equal [
      { ["a"].is.namelist?          =>  true  },
      { ["a@b"].is.namelist?        =>  true  },
      { ["a" * 64].is.namelist?     =>  true  },

      { [""].is.namelist?           =>  false  },
      { ["a" * 65].is.namelist?     =>  false  },
      { ["a,b"].is.namelist?        =>  false  },
      { ["@a"].is.namelist?         =>  false  },
      { ["a@"].is.namelist?         =>  false  },
      { ["@a@b"].is.namelist?       =>  false  },
      { ["a@b@"].is.namelist?       =>  false  },
      { ["a@b@c"].is.namelist?      =>  false  },
      { [" ab"].is.namelist?        =>  false  },
      { ["ab "].is.namelist?        =>  false  },
      { ["a b"].is.namelist?        =>  false  },
      { ["\n"].is.namelist?         =>  false  },
      { ["\x7f"].is.namelist?       =>  false  },

      { ["a",""].is.namelist?         =>  false  },
      { ["a",("a" * 65)].is.namelist? =>  false  },
      { ["a","a,b"].is.namelist?      =>  false  },
      { ["a","@a"].is.namelist?       =>  false  },
      { ["a","a@"].is.namelist?       =>  false  },
      { ["a","@a@b"].is.namelist?     =>  false  },
      { ["a","a@b@"].is.namelist?     =>  false  },
      { ["a","a@b@c"].is.namelist?    =>  false  },
      { ["a"," ab"].is.namelist?      =>  false  },
      { ["a","ab "].is.namelist?      =>  false  },
      { ["a","a b"].is.namelist?      =>  false  },
      { ["a","\n"].is.namelist?       =>  false  },
      { ["a","\x7f"].is.namelist?     =>  false  },

      { ["a",1].is.namelist?          =>  false  },
      { ["a",:a].is.namelist?         =>  false  },
      { ["a",[]].is.namelist?         =>  false  },
      { ["a",true].is.namelist?       =>  false  },
      { ["a",nil].is.namelist?        =>  false  },

      { 1.is.namelist?                =>  false  },
      { :a.is.namelist?               =>  false  },
      { "a,b".is.namelist?            =>  false  },
      { true.is.namelist?             =>  false  },
      { nil.is.namelist?              =>  false  },
    ]
  end

  def test_bytes?
    try_assert_equal [
      { [0].is.bytes?              =>  true  },
      { [1].is.bytes?              =>  true  },
      { [0,255,1,255].is.bytes?    =>  true  },

      { [-1].is.bytes?             =>  false  },
      { [256].is.bytes?            =>  false  },
      { [0,255,1,256].is.bytes?    =>  false  },

      { [0,255,1,"1"   ].is.bytes? =>  false  },
      { [0,255,1,1.0   ].is.bytes? =>  false  },
      { [0,255,1,:a    ].is.bytes? =>  false  },
      { [0,255,1,nil   ].is.bytes? =>  false  },
      { [0,255,1,false ].is.bytes? =>  false  },

      { 1.is.bytes?          =>  false  },
      { :a.is.bytes?         =>  false  },
      { "a,b".is.bytes?      =>  false  },
      { true.is.bytes?       =>  false  },
      { nil.is.bytes?        =>  false  },
    ]
  end

  def test_type__boolean?
    try_assert_equal [
      { true.is.type?(:boolean)  =>  true  },
      { false.is.type?(:boolean) =>  true  },

      { nil.is.type?(:boolean)  =>  false  },
      { 0.is.type?(:boolean)    =>  false  },
    ]
  end

  def test_type__byte?
    try_assert_equal [
      { 0.is.type?(:byte)        =>  true  },
      { 1.is.type?(:byte)        =>  true  },
      { 255.is.type?(:byte)      =>  true  },

      { 1.0.is.type?(:byte)     =>  false  },
      { -1.is.type?(:byte)      =>  false  },
      { 256.is.type?(:byte)     =>  false  },
      { "0".is.type?(:byte)     =>  false  },
      { "".is.type?(:byte)      =>  false  },
      { [].is.type?(:byte)      =>  false  },
    ]
  end

  def test_type__uint32?
    try_assert_equal [
      { 0.is.type?(:uint32)           =>  true  },
      { 1.is.type?(:uint32)           =>  true  },
      { 255.is.type?(:uint32)         =>  true  },
      { ((1<<32)-1).is.type?(:uint32) =>  true  },

      { 1.0.is.type?(:uint32)     =>  false  },
      { -1.is.type?(:uint32)      =>  false  },
      { (1<<32).is.type?(:uint32) =>  false  },
      { "0".is.type?(:uint32)     =>  false  },
      { "".is.type?(:uint32)      =>  false  },
      { [].is.type?(:uint32)      =>  false  },
    ]
  end

  def test_type__uint64?
    try_assert_equal [
      { 0.is.type?(:uint64)           =>  true  },
      { 1.is.type?(:uint64)           =>  true  },
      { 255.is.type?(:uint64)         =>  true  },
      { ((1<<64)-1).is.type?(:uint64) =>  true  },

      { 1.0.is.type?(:uint64)     =>  false  },
      { -1.is.type?(:uint64)      =>  false  },
      { (1<<64).is.type?(:uint64) =>  false  },
      { "0".is.type?(:uint64)     =>  false  },
      { "".is.type?(:uint64)      =>  false  },
      { [].is.type?(:uint64)      =>  false  },
    ]
  end

  def test_type__mpint?
    try_assert_equal [
      { @bn0.is.type?(:mpint)    =>  true  },
      { @bn1.is.type?(:mpint)    =>  true  },

      { 1.is.type?(:mpint)       =>  false  },
      { 1.0.is.type?(:mpint)     =>  false  },
      { -1.is.type?(:mpint)      =>  false  },
      { (1<<64).is.type?(:mpint) =>  false  },
      { "0".is.type?(:mpint)     =>  false  },
      { "".is.type?(:mpint)      =>  false  },
      { [].is.type?(:mpint)      =>  false  },
    ]
  end

  def test_type__string?
    try_assert_equal [
      { "".is.type?(:string)          =>  true  },
      { "a".is.type?(:string)         =>  true  },
      { "a@@b".is.type?(:string)      =>  true  },
      { "a,b".is.type?(:string)       =>  true  },
      { ("a"*65).is.type?(:string)    =>  true  },

      { 1.is.type?(:string)      =>  false  },
      { [].is.type?(:string)     =>  false  },
      { false.is.type?(:string)  =>  false  },
      { nil.is.type?(:string)    =>  false  },
      { true.is.type?(:string)   =>  false  },
    ]
  end

  def test_type__name?
    try_assert_equal [
      { "a".is.type?(:name)         =>  true  },
      { ("a"*64).is.type?(:name)    =>  true  },

      { "".is.type?(:name)       =>  false  },
      { ("a"*65).is.type?(:name) =>  false  },
      { "a@@b".is.type?(:name)   =>  false  },
      { "a,b".is.type?(:name)    =>  false  },
      { ["a"].is.type?(:name)    =>  false  },
    ]
  end

  def test_type__namelist?
    try_assert_equal [
      { ["a"].is.type?(:namelist)       =>  true  },
      { ["a","b"].is.type?(:namelist)   =>  true  },
      { ["a"*64].is.type?(:namelist)    =>  true  },

      { [""].is.type?(:namelist)          =>  false  },
      { ["a",""].is.type?(:namelist)      =>  false  },
      { ["a"*65].is.type?(:namelist)      =>  false  },
      { ["a",nil,"b"].is.type?(:namelist) =>  false  },
      { ["@","a"].is.type?(:namelist)     =>  false  },
      { ["a@","a"].is.type?(:namelist)    =>  false  },
    ]
  end

  def test_type__bytes?
    try_assert_equal [
      { [1].is.type?(1)           =>  true  },
      { [0,255,255].is.type?(3)   =>  true  },

      { [].is.type?(0)              =>  false  },
      { [0,255,255].is.type?(2)     =>  false  },
      { [0,255,255].is.type?(4)     =>  false  },
      { [0,255,256].is.type?(3)     =>  false  },
      { [-1,255,255].is.type?(3)    =>  false  },
      { [1.0,255,255].is.type?(3)   =>  false  },
      { ["1",255,255].is.type?(3)   =>  false  },
      { [:a,255,255].is.type?(3)    =>  false  },
      { [nil,255,255].is.type?(3)   =>  false  },
      { [false,255,255].is.type?(3) =>  false  },
    ]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

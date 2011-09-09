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
=begin
  def test_boolean?
    try_assert_equal [
      { true.ssh.boolean?              =>  true   },
      { false.ssh.boolean?             =>  true   },

      { nil.ssh.boolean?               =>  false  },
      { 0.ssh.boolean?                 =>  false  },
      { 0.0.ssh.boolean?               =>  false  },
      { "".ssh.boolean?                =>  false  },
      { " ".ssh.boolean?               =>  false  },
      { "0".ssh.boolean?               =>  false  },
      { [].ssh.boolean?                =>  false  },
      { [0].ssh.boolean?               =>  false  },
      { {}.ssh.boolean?                =>  false  },
      { :true.ssh.boolean?             =>  false  },
    ]
  end

  def test_byte?
    try_assert_equal [
      { 0.ssh.byte?                    =>  true   },
      { 1.ssh.byte?                    =>  true   },
      { 255.ssh.byte?                  =>  true   },

      { -1.ssh.byte?                   =>  false  },
      { 256.ssh.byte?                  =>  false  },
      { true.ssh.byte?                 =>  false  },
      { false.ssh.byte?                =>  false  },
      { nil.ssh.byte?                  =>  false  },
      { 0.0.ssh.byte?                  =>  false  },
      { "1".ssh.byte?                  =>  false  },
      { [1].ssh.byte?                  =>  false  },
      { {}.ssh.byte?                   =>  false  },
      { :true.ssh.byte?                =>  false  },
    ]
  end

  def test_uint32?
    try_assert_equal [
      { 0.ssh.uint32?                  =>  true   },
      { 1.ssh.uint32?                  =>  true   },
      { ((1<<32)-1).ssh.uint32?        =>  true   },

      { -1.ssh.uint32?                 =>  false  },
      { (1<<32).ssh.uint32?            =>  false  },
      { true.ssh.uint32?               =>  false  },
      { false.ssh.uint32?              =>  false  },
      { nil.ssh.uint32?                =>  false  },
      { 0.0.ssh.uint32?                =>  false  },
      { "1".ssh.uint32?                =>  false  },
      { [1].ssh.uint32?                =>  false  },
      { {}.ssh.uint32?                 =>  false  },
      { :true.ssh.uint32?              =>  false  },
    ]
  end

  def test_uint64?
    try_assert_equal [
      { 0.ssh.uint64?                  =>  true   },
      { 1.ssh.uint64?                  =>  true   },
      { ((1<<64)-1).ssh.uint64?        =>  true   },

      { -1.ssh.uint64?                 =>  false  },
      { (1<<64).ssh.uint64?            =>  false  },
      { true.ssh.uint64?               =>  false  },
      { false.ssh.uint64?              =>  false  },
      { nil.ssh.uint64?                =>  false  },
      { 0.0.ssh.uint64?                =>  false  },
      { "1".ssh.uint64?                =>  false  },
      { [1].ssh.uint64?                =>  false  },
      { {}.ssh.uint64?                 =>  false  },
      { :true.ssh.uint64?              =>  false  },
    ]
  end

  def test_mpint?
    try_assert_equal [
      { @bn0.ssh.mpint?                =>  true   },
      { @bn1.ssh.mpint?                =>  true   },
      { @bn1234h.ssh.mpint?            =>  true   },
      { @bn8000h.ssh.mpint?            =>  true   },
      { @bn_1234h.ssh.mpint?           =>  true   },
      { @bn_beefh.ssh.mpint?           =>  true   },

      { 0.ssh.mpint?                   =>  false  },
      { 1.ssh.mpint?                   =>  false  },
      { -1.ssh.mpint?                  =>  false  },
      { 100.ssh.mpint?                 =>  false  },
      { true.ssh.mpint?                =>  false  },
      { false.ssh.mpint?               =>  false  },
      { nil.ssh.mpint?                 =>  false  },
      { 0.0.ssh.mpint?                 =>  false  },
      { "1".ssh.mpint?                 =>  false  },
      { [1].ssh.mpint?                 =>  false  },
      { {}.ssh.mpint?                  =>  false  },
      { :true.ssh.mpint?               =>  false  },
    ]
  end

  def test_string?
    try_assert_equal [
      { "".ssh.string?                =>  true  },
      { "a".ssh.string?               =>  true  },
      { "hello".ssh.string?           =>  true  },
      { "a,b".ssh.string?             =>  true  },
      { ",ab".ssh.string?             =>  true  },
      { "ab,".ssh.string?             =>  true  },
      { "a,,b".ssh.string?            =>  true  },
      { ",a,b".ssh.string?            =>  true  },
      { "a,b,".ssh.string?            =>  true  },
      { "@a".ssh.string?              =>  true  },
      { "a@".ssh.string?              =>  true  },
      { "a@b".ssh.string?             =>  true  },
      { "@a@b".ssh.string?            =>  true  },
      { "a@b@".ssh.string?            =>  true  },
      { "a@b@c".ssh.string?           =>  true  },
      { "a@@c".ssh.string?            =>  true  },
      { "a b".ssh.string?             =>  true  },
      { " ab".ssh.string?             =>  true  },
      { "ab ".ssh.string?             =>  true  },
      { "a b".ssh.string?             =>  true  },
      { ("a" * 65).ssh.string?        =>  true  },
      { "\n".ssh.string?              =>  true  },
      { "\r\n".ssh.string?            =>  true  },
      { "a\r\n".ssh.string?           =>  true  },
      { "a\n".ssh.string?             =>  true  },
      { " a\tb".ssh.string?           =>  true  },
      { "a\x7fb".ssh.string?          =>  true  },
      { "\x01abc".ssh.string?         =>  true  },

      { 1.ssh.string?                 =>  false  },
      { :a.ssh.string?                =>  false  },
      { [].ssh.string?                =>  false  },
      { true.ssh.string?              =>  false  },
      { nil.ssh.string?               =>  false  },
    ]
  end


  def test_namelist?
    try_assert_equal [
      { ["a"].ssh.namelist?          =>  true  },
      { ["a@b"].ssh.namelist?        =>  true  },
      { ["a" * 64].ssh.namelist?     =>  true  },

      { [""].ssh.namelist?           =>  false  },
      { ["a" * 65].ssh.namelist?     =>  false  },
      { [",a"].ssh.namelist?         =>  false  },
      { ["a,"].ssh.namelist?         =>  false  },
      { ["a,b"].ssh.namelist?        =>  false  },
      { ["a", " b"].ssh.namelist?    =>  false  },
      { ["@a"].ssh.namelist?         =>  false  },
      { ["a@"].ssh.namelist?         =>  false  },
      { ["@a@b"].ssh.namelist?       =>  false  },
      { ["a@b@"].ssh.namelist?       =>  false  },
      { ["a@b@c"].ssh.namelist?      =>  false  },
      { ["a@@c"].ssh.namelist?       =>  false  },
      { [" "].ssh.namelist?          =>  false  },
      { [" ab"].ssh.namelist?        =>  false  },
      { ["ab "].ssh.namelist?        =>  false  },
      { ["a b"].ssh.namelist?        =>  false  },
      { ["a\n"].ssh.namelist?        =>  false  },
      { ["\n"].ssh.namelist?         =>  false  },
      { ["\x7f"].ssh.namelist?       =>  false  },

      { ["a",""].ssh.namelist?         =>  false  },
      { ["a",("a" * 65)].ssh.namelist? =>  false  },
      { ["a","a,b"].ssh.namelist?      =>  false  },
      { ["a","@a"].ssh.namelist?       =>  false  },
      { ["a","a@"].ssh.namelist?       =>  false  },
      { ["a","@a@b"].ssh.namelist?     =>  false  },
      { ["a","a@b@"].ssh.namelist?     =>  false  },
      { ["a","a@b@c"].ssh.namelist?    =>  false  },
      { ["a"," ab"].ssh.namelist?      =>  false  },
      { ["a","ab "].ssh.namelist?      =>  false  },
      { ["a","a b"].ssh.namelist?      =>  false  },
      { ["a","\n"].ssh.namelist?       =>  false  },
      { ["a","\x7f"].ssh.namelist?     =>  false  },

      { ["a",1].ssh.namelist?          =>  false  },
      { ["a",:a].ssh.namelist?         =>  false  },
      { ["a",[]].ssh.namelist?         =>  false  },
      { ["a",true].ssh.namelist?       =>  false  },
      { ["a",nil].ssh.namelist?        =>  false  },

      { 1.ssh.namelist?                =>  false  },
      { :a.ssh.namelist?               =>  false  },
      { "a,b".ssh.namelist?            =>  false  },
      { true.ssh.namelist?             =>  false  },
      { nil.ssh.namelist?              =>  false  },
    ]
  end

  def test_bytes?
    try_assert_equal [
      { [0].ssh.bytes?              =>  true  },
      { [1].ssh.bytes?              =>  true  },
      { [0,255,1,255].ssh.bytes?    =>  true  },

      { [-1].ssh.bytes?             =>  false  },
      { [256].ssh.bytes?            =>  false  },
      { [0,255,1,256].ssh.bytes?    =>  false  },

      { [0,255,1,"1"   ].ssh.bytes? =>  false  },
      { [0,255,1,1.0   ].ssh.bytes? =>  false  },
      { [0,255,1,:a    ].ssh.bytes? =>  false  },
      { [0,255,1,nil   ].ssh.bytes? =>  false  },
      { [0,255,1,false ].ssh.bytes? =>  false  },

      { 1.ssh.bytes?          =>  false  },
      { :a.ssh.bytes?         =>  false  },
      { "a,b".ssh.bytes?      =>  false  },
      { true.ssh.bytes?       =>  false  },
      { nil.ssh.bytes?        =>  false  },
    ]
  end
=end
  def test_type__boolean?
    try_assert_equal [
      { true.ssh.type?(:boolean)  =>  true  },
      { false.ssh.type?(:boolean) =>  true  },

      { nil.ssh.type?(:boolean)  =>  false  },
      { 0.ssh.type?(:boolean)    =>  false  },
    ]
  end

  def test_type__byte?
    try_assert_equal [
      { 0.ssh.type?(:byte)        =>  true  },
      { 1.ssh.type?(:byte)        =>  true  },
      { 255.ssh.type?(:byte)      =>  true  },

      { 1.0.ssh.type?(:byte)     =>  false  },
      { -1.ssh.type?(:byte)      =>  false  },
      { 256.ssh.type?(:byte)     =>  false  },
      { "0".ssh.type?(:byte)     =>  false  },
      { "".ssh.type?(:byte)      =>  false  },
      { [].ssh.type?(:byte)      =>  false  },
    ]
  end

  def test_type__uint32?
    try_assert_equal [
      { 0.ssh.type?(:uint32)           =>  true  },
      { 1.ssh.type?(:uint32)           =>  true  },
      { 255.ssh.type?(:uint32)         =>  true  },
      { ((1<<32)-1).ssh.type?(:uint32) =>  true  },

      { 1.0.ssh.type?(:uint32)     =>  false  },
      { -1.ssh.type?(:uint32)      =>  false  },
      { (1<<32).ssh.type?(:uint32) =>  false  },
      { "0".ssh.type?(:uint32)     =>  false  },
      { "".ssh.type?(:uint32)      =>  false  },
      { [].ssh.type?(:uint32)      =>  false  },
    ]
  end

  def test_type__uint64?
    try_assert_equal [
      { 0.ssh.type?(:uint64)           =>  true  },
      { 1.ssh.type?(:uint64)           =>  true  },
      { 255.ssh.type?(:uint64)         =>  true  },
      { ((1<<64)-1).ssh.type?(:uint64) =>  true  },

      { 1.0.ssh.type?(:uint64)     =>  false  },
      { -1.ssh.type?(:uint64)      =>  false  },
      { (1<<64).ssh.type?(:uint64) =>  false  },
      { "0".ssh.type?(:uint64)     =>  false  },
      { "".ssh.type?(:uint64)      =>  false  },
      { [].ssh.type?(:uint64)      =>  false  },
    ]
  end

  def test_type__mpint?
    try_assert_equal [
      { @bn0.ssh.type?(:mpint)    =>  true  },
      { @bn1.ssh.type?(:mpint)    =>  true  },

      { 1.ssh.type?(:mpint)       =>  false  },
      { 1.0.ssh.type?(:mpint)     =>  false  },
      { -1.ssh.type?(:mpint)      =>  false  },
      { (1<<64).ssh.type?(:mpint) =>  false  },
      { "0".ssh.type?(:mpint)     =>  false  },
      { "".ssh.type?(:mpint)      =>  false  },
      { [].ssh.type?(:mpint)      =>  false  },
    ]
  end

  def test_type__string?
    try_assert_equal [
      { "".ssh.type?(:string)          =>  true  },
      { "a".ssh.type?(:string)         =>  true  },
      { "a@@b".ssh.type?(:string)      =>  true  },
      { "a,b".ssh.type?(:string)       =>  true  },
      { ("a"*65).ssh.type?(:string)    =>  true  },

      { 1.ssh.type?(:string)      =>  false  },
      { [].ssh.type?(:string)     =>  false  },
      { false.ssh.type?(:string)  =>  false  },
      { nil.ssh.type?(:string)    =>  false  },
      { true.ssh.type?(:string)   =>  false  },
    ]
  end

  def test_type__namelist?
    try_assert_equal [
      { ["a"].ssh.type?(:namelist)       =>  true  },
      { ["a","b"].ssh.type?(:namelist)   =>  true  },
      { ["a"*64].ssh.type?(:namelist)    =>  true  },

      { [""].ssh.type?(:namelist)          =>  false  },
      { ["a",""].ssh.type?(:namelist)      =>  false  },
      { ["a"*65].ssh.type?(:namelist)      =>  false  },
      { ["a",nil,"b"].ssh.type?(:namelist) =>  false  },
      { ["@","a"].ssh.type?(:namelist)     =>  false  },
      { ["a@","a"].ssh.type?(:namelist)    =>  false  },
    ]
  end

  def test_type__bytes?
    try_assert_equal [
      { [1].ssh.type?(1)           =>  true  },
      { [0,255,255].ssh.type?(3)   =>  true  },

      { [].ssh.type?(0)              =>  false  },
      { [0,255,255].ssh.type?(2)     =>  false  },
      { [0,255,255].ssh.type?(4)     =>  false  },
      { [0,255,256].ssh.type?(3)     =>  false  },
      { [-1,255,255].ssh.type?(3)    =>  false  },
      { [1.0,255,255].ssh.type?(3)   =>  false  },
      { ["1",255,255].ssh.type?(3)   =>  false  },
      { [:a,255,255].ssh.type?(3)    =>  false  },
      { [nil,255,255].ssh.type?(3)   =>  false  },
      { [false,255,255].ssh.type?(3) =>  false  },
    ]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

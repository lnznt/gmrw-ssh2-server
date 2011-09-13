# -*- coding: ascii -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'test/unit'
require 'openssl'
require 'gmrw/ssh2/message/datatype'

class TestField < Test::Unit::TestCase
  include GMRW::SSH2

  def try_assert_equal(tests)
    tests.each_with_index do |test, i|
      actual, expected = test.first
      assert_equal(expected, actual, "case##{i}")
    end
  end

  def setup
    @bn       = OpenSSL::BN.new(1.to_s)
    @bn0      = OpenSSL::BN.new(0.to_s)
    @bn1      = OpenSSL::BN.new(1.to_s)
    @bn1234h  = OpenSSL::BN.new(0x1234.to_s)
    @bn8000h  = OpenSSL::BN.new(0x8000.to_s)
    @bn_1234h = OpenSSL::BN.new((-0x1234).to_s)
    @bn_beefh = OpenSSL::BN.new((-0xbeef).to_s)
  end

  def test_default
    try_assert_equal [
      { ssh.default(:boolean)   =>  false   },
      { ssh.default(:byte)      =>  0       },
      { ssh.default(:uint32)    =>  0       },
      { ssh.default(:uint64)    =>  0       },
      { ssh.default(:mpint)     =>  OpenSSL::BN.new(0.to_s) },
      { ssh.default(:string)    =>  ""      },
      { ssh.default(:namelist)  =>  []      },
      { ssh.default(1).length   =>  1       },
      { ssh.default(4).length   =>  4       },

      { ssh.default(0)          =>  nil     },
      { ssh.default(1.0)        =>  nil     },
      { ssh.default(:xxx)       =>  nil     },
      { ssh.default("")         =>  nil     },
      { ssh.default(true)       =>  nil     },
      { ssh.default(false)      =>  nil     },
      { ssh.default(nil)        =>  nil     },
    ]
  end

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

  def test_encode__boolean
    try_assert_equal [
      { true.ssh.encode(:boolean)  => [1].pack("C") },
      { false.ssh.encode(:boolean) => [0].pack("C") },
    ]
  end

  def test_encode__byte
    try_assert_equal [
      { 0.ssh.encode(:byte)     => [0].pack("C") },
      { 1.ssh.encode(:byte)     => [1].pack("C") },
      { 255.ssh.encode(:byte)   => [255].pack("C") },
    ]
  end

  def test_encode__uint32
    try_assert_equal [
      { 0.ssh.encode(:uint32)           => [0].pack("N") },
      { 1.ssh.encode(:uint32)           => [1].pack("N") },
      { 255.ssh.encode(:uint32)         => [255].pack("N") },
      { ((1<<32)-1).ssh.encode(:uint32) => [(1<<32)-1].pack("N") },
    ]
  end

  def test_encode__uint64
    try_assert_equal [
      { 0.ssh.encode(:uint64)           => [0,0].pack("NN") },
      { 1.ssh.encode(:uint64)           => [0,1].pack("NN") },
      { 255.ssh.encode(:uint64)         => [0,255].pack("NN") },
      { ((1<<64)-1).ssh.encode(:uint64) => [(1<<32)-1,(1<<32)-1].pack("NN") },
    ]
  end

  def test_encode__string
    try_assert_equal [
      { "".ssh.encode(:string)       => [0,""].pack("Na*") },
      { "a".ssh.encode(:string)      => [1,"a"].pack("Na*") },
      { "\n".ssh.encode(:string)     => [1,"\n"].pack("Na*") },
      { ("a"*65).ssh.encode(:string) => [65,"a"*65].pack("Na*") },
    ]
  end

  def test_encode__namelist
    try_assert_equal [
      { ["a"].ssh.encode(:namelist)             => [1,"a"].pack("Na*") },
      { ["a","b"].ssh.encode(:namelist)         => [3,"a,b"].pack("Na*") },
      { ["a","b","c"].ssh.encode(:namelist)     => [5,"a,b,c"].pack("Na*") },
      { ["a"*64].ssh.encode(:namelist)          => [64,"a"*64].pack("Na*") },
    ]
  end

  def test_encode__bytes
    try_assert_equal [
      { [0].ssh.encode(1)          => [0].pack("C*") },
      { [0,1,255].ssh.encode(3)    => [0,1,255].pack("C*") },
    ]
  end

  def test_encode__mpint
    bn0     = OpenSSL::BN.new(0.to_s)
    bn1     = OpenSSL::BN.new(1.to_s)
    bn1234h = OpenSSL::BN.new(0x1234.to_s)
    bn8000h = OpenSSL::BN.new(0x8000.to_s)
    bn_1234h = OpenSSL::BN.new((-0x1234).to_s)
    bn_beefh = OpenSSL::BN.new((-0xbeef).to_s)
    
    try_assert_equal [
      { bn0.ssh.encode(:mpint)         => [0].pack("N") },
      { bn1.ssh.encode(:mpint)         => [1,1].pack("NC*") },
      { bn1234h.ssh.encode(:mpint)     => [2,0x12,0x34].pack("NC*") },
      { bn8000h.ssh.encode(:mpint)     => [3,0x00,0x80,0x00].pack("NC*") },
      { bn_1234h.ssh.encode(:mpint)    => [2,0xed,0xcc].pack("NC*") },
      { bn_beefh.ssh.encode(:mpint)    => [3,0xff,0x41,0x11].pack("NC*") },
    ]
  end

  def test_decode__boolean
    try_assert_equal [
      { [0x00].pack("C").ssh.decode(:boolean)        => [false, ""] },
      { [0x00,0x01].pack("CC").ssh.decode(:boolean)  => [false, "\x01"] },
      { [0x01].pack("C").ssh.decode(:boolean)        => [true, ""] },
      { [0x02].pack("C").ssh.decode(:boolean)        => [true, ""] },
      { [0xff].pack("C").ssh.decode(:boolean)        => [true, ""] },
    ]
  end

  def test_decode__byte
    try_assert_equal [
      { [0x00].pack("C").ssh.decode(:byte)        => [0x00, ""] },
      { [0x00,0x01].pack("CC").ssh.decode(:byte)  => [0x00, "\x01"] },
      { [0x01].pack("C").ssh.decode(:byte)        => [0x01, ""] },
      { [0x02].pack("C").ssh.decode(:byte)        => [0x02, ""] },
      { [0xff].pack("C").ssh.decode(:byte)        => [0xff, ""] },
    ]
  end

  def test_decode__uint32
    try_assert_equal [
      { [0x00].pack("N").ssh.decode(:uint32)        => [0x00, ""] },
      { [0x00,0x01].pack("NC").ssh.decode(:uint32)  => [0x00, "\x01"] },
      { [0x01].pack("N").ssh.decode(:uint32)        => [0x01, ""] },
      { [0x02].pack("N").ssh.decode(:uint32)        => [0x02, ""] },
      { [0xffff_ffff].pack("N").ssh.decode(:uint32)  => [0xffff_ffff, ""] },
    ]
  end

  def test_decode__uint64
    try_assert_equal [
      { [0x00,0x00].pack("NN").ssh.decode(:uint64)        => [0x00, ""] },
      { [0x00,0x00,0x01].pack("NNC").ssh.decode(:uint64)  => [0x00, "\x01"] },
      { [0x00,0x01].pack("NN").ssh.decode(:uint64)        => [0x01, ""] },
      { [0x01,0x02].pack("NN").ssh.decode(:uint64)        => [0x01_0000_0002, ""] },
      { [0xffff_ffff,0xffff_ffff].pack("NN").ssh.decode(:uint64)  => [0xffff_ffff_ffff_ffff, ""] },
    ]
  end

  def test_decode__mpint
    try_assert_equal [
      { [0,"hello"].pack("Na*").ssh.decode(:mpint)              => [0, "hello"] },
      { [2,0x12,0x34,"hello"].pack("NCCa*").ssh.decode(:mpint)  => [0x1234, "hello"] },
      { [2,0xed,0xcc,"hello"].pack("NCCa*").ssh.decode(:mpint)  => [-0x1234, "hello"] },
      { [3,0x00,0x80,0x00,"hello"].pack("NC3a*").ssh.decode(:mpint)  => [0x8000, "hello"] },
      { [3,0xff,0x41,0x11,"hello"].pack("NC3a*").ssh.decode(:mpint)  => [-0xbeef, "hello"] },

      { [0].pack("N").ssh.decode(:mpint)              => [0, ""] },
      { [2,0x12,0x34].pack("NCC").ssh.decode(:mpint)  => [0x1234, ""] },
    ]
  end

  def test_decode__string
    try_assert_equal [
      { [5,"hello"].pack("Na*").ssh.decode(:string)        => ["hello", ""] },
      { [5,"hello,world"].pack("Na*").ssh.decode(:string)  => ["hello", ",world"] },
      { [0,"hello"].pack("Na*").ssh.decode(:string)        => ["", "hello"] },
    ]
  end

  def test_decode__namelist
    try_assert_equal [
      { [5,"hello"].pack("Na*").ssh.decode(:namelist)        => [["hello"], ""] },
      { [9,"hello,world"].pack("Na*").ssh.decode(:namelist)  => [["hello", "wor"],"ld"] },
      { [0,"hello"].pack("Na*").ssh.decode(:namelist)        => [[], "hello"] },
    ]
  end

  def test_decode__bytes
    try_assert_equal [
      { [1,2,3,4].pack("C*").ssh.decode(4)          => [[1,2,3,4], ""] },
      { [1,2,3,4].pack("C*").ssh.decode(3)          => [[1,2,3], "\x04"] },
      { [1,2,3,"hello"].pack("C3a*").ssh.decode(3)  => [[1,2,3],"hello"] },
    ]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

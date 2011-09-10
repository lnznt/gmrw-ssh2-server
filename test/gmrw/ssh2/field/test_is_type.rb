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

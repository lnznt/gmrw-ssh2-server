# -*- coding: ascii -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'test/unit'
require 'gmrw/extension/object'

class TestField < Test::Unit::TestCase
  def try_assert_equal(tests)
    tests.each_with_index do |test, i|
      actual, expected = test.first
      assert_equal(expected, actual, "case##{i}")
    end
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
      { :undefined.is.boolean?        =>  false  },
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

  def test_integer?
    try_assert_equal [
      { 0.is.integer?                =>  true   },
      { 1.is.integer?                =>  true   },
      { 0x1234.is.integer?           =>  true   },
      { -0x1234.is.integer?          =>  true   },
      { (1<<65).is.integer?          =>  true   },

      { true.is.integer?             =>  false  },
      { false.is.integer?            =>  false  },
      { nil.is.integer?              =>  false  },
      { 0.0.is.integer?              =>  false  },
      { "1".is.integer?              =>  false  },
      { [1].is.integer?              =>  false  },
      { {}.is.integer?               =>  false  },
      { :true.is.integer?            =>  false  },
    ]
  end

  def test_string?
    try_assert_equal [
      { "".is.string?              =>  true  },
      { "a".is.string?             =>  true  },
      { "hello".is.string?         =>  true  },
      { "a,b".is.string?           =>  true  },
      { "a@b".is.string?           =>  true  },
      { "a b".is.string?           =>  true  },
      { " ab".is.string?           =>  true  },
      { "ab ".is.string?           =>  true  },
      { "a b".is.string?           =>  true  },
      { ("a" * 65).is.string?      =>  true  },
      { "a\r\n".is.string?         =>  true  },
      { " a\tb".is.string?         =>  true  },
      { "a\x7fb".is.string?        =>  true  },
      { "\x01abc".is.string?       =>  true  },

      { 1.is.string?               =>  false  },
      { :a.is.string?              =>  false  },
      { [].is.string?              =>  false  },
      { true.is.string?            =>  false  },
      { nil.is.string?             =>  false  },
    ]
  end

  def test_symbol?
    try_assert_equal [
      { :a.is.symbol?              =>  true  },

      { "".is.symbol?              =>  false  },
      { 0.is.symbol?               =>  false  },
      { 0.0.is.symbol?             =>  false  },
      { [].is.symbol?              =>  false  },
      { true.is.symbol?            =>  false  },
      { nil.is.symbol?             =>  false  },
    ]
  end

  def test_array?
    try_assert_equal [
      { [].is.array?              =>  true  },
      { ["a"].is.array?           =>  true  },
      { ["a@b",1,2].is.array?     =>  true  },
      { ["a",:a,{}].is.array?     =>  true  },

      { {[1]=>10}.is.array?       =>  false  },
      { 1.is.array?               =>  false  },
      { :a.is.array?              =>  false  },
      { "a,b".is.array?           =>  false  },
      { true.is.array?            =>  false  },
      { nil.is.array?             =>  false  },
    ]
  end

  def test_hash?
    try_assert_equal [
      { {}.is.hash?                =>  true  },
      { {:a=>0}.is.hash?           =>  true  },
      { {:a=>[],:b=>10}.is.hash?   =>  true  },

      { 1.is.hash?                 =>  false  },
      { [1].is.hash?               =>  false  },
      { :a.is.hash?                =>  false  },
      { "a,b".is.hash?             =>  false  },
      { true.is.hash?              =>  false  },
      { nil.is.hash?               =>  false  },
    ]
  end

  def test_proc?
    try_assert_equal [
      { proc{}.is.proc?            =>  true  },
      { lambda{}.is.proc?          =>  true  },

      { 1.is.proc?                 =>  false  },
      { [1].is.proc?               =>  false  },
      { {:a=>10}.is.proc?          =>  false  },
      { :a.is.proc?                =>  false  },
      { "a,b".is.proc?             =>  false  },
      { true.is.proc?              =>  false  },
      { nil.is.proc?               =>  false  },
    ]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

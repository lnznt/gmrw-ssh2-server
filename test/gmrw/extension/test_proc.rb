# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'test/unit'
require 'gmrw/extension/proc'

class TestFields < Test::Unit::TestCase
  def try_assert_equal(tests)
    tests.each_with_index do |test, i|
      actual, expected = test.first
      assert_equal(expected, actual, "case##{i}")
    end
  end

  def setup
    @add    = lambda {|a, b| a + b  }
    @sub    = lambda {|a, b| a - b  }
    @add_3  = lambda {|a, b, c| a + b + c }
    @sub_3  = lambda {|a, b, c| a - b - c }
    @mul10  = lambda {|a   | a * 10 }
    @div5   = lambda {|a   | a / 5  }
    @divmod = lambda {|a, b| a.divmod(b) }

    @upper    = proc {|s| s.upcase       }
    @center15 = proc {|s| s.center(15)   }
    @wrap     = proc {|s| "bar#{s}baz"   }
  end

  def test_compose
    try_assert_equal [
      {  (        @mul10 * @add )[1,2]  => 30 },
      {  (@div5 * @mul10 * @add )[1,2]  => 6  },

      {  (@center15 * @wrap * @upper)["foo"] => "   barFOObaz   "       },
      {  (@upper * @wrap * @center15)["foo"] => "BAR      FOO      BAZ" },
    ]
  end

  def test_scompose
    try_assert_equal [
      {  (@add & @divmod)[10, 7] => 4 },
    ]
  end

  def test_rcompose
    try_assert_equal [
      {  (@add  % @mul10        )[1,2]  => 30 },
      {  (@add  % @mul10 % @div5)[1,2]  => 6  },
      {  (@center15 % @wrap % @upper)["foo"] => "BAR      FOO      BAZ" },
      {  (@upper % @wrap % @center15)["foo"] => "   barFOObaz   "       },
    ]
  end

  def test_srcompose
    try_assert_equal [
      {  (@divmod | @add)[10, 7] => 4 },
    ]
  end

  def test_first_arg
    try_assert_equal [
      { (@add << 1)[2]           => 3 },
      { @add.first_arg(1,2)[]    => 3 },
      { @add_3.first_arg(1,2)[3] => 6 },

      { (@sub << 1)[2]           => -1 },
      { @sub.first_arg(1,2)[]    => -1 },
      { @sub_3.first_arg(1,2)[3] => -4 },
    ]
  end

  def test_last_arg
    try_assert_equal [
      { (@add >> 1)[2]          => 3 },
      { @add.last_arg(1,2)[]    => 3 },
      { @add_3.last_arg(1,2)[3] => 6 },

      { (@sub >> 1)[5]           => 4 },
      { @sub.last_arg(5,1)[]     => 4 },
      { @sub_3.last_arg(5,1)[9]  => 3 },
    ]
  end

  def test_t
    try_assert_equal [
      { Proc.t[]                 => true },
      { Proc.t[1,2,3]            => true },
      { Proc.t[nil]              => true },
      { Proc.t[true]             => true },
      { Proc.t[false]            => true }, #!!
    ]
  end

  def test_f
    try_assert_equal [
      { Proc.f[]                 => false },
      { Proc.f[1,2,3]            => false },
      { Proc.f[nil]              => false },
      { Proc.f[true]             => false },  #!!
      { Proc.f[false]            => false },
    ]
  end

  def test_n
    try_assert_equal [
      { Proc.n[]                 => nil },
      { Proc.n[1,2,3]            => nil },
      { Proc.n[nil]              => nil },
      { Proc.n[true]             => nil },
      { Proc.n[false]            => nil },
    ]
  end

  def test_as_is
    try_assert_equal [
      { Proc.as_is[]             => nil     },
      { Proc.as_is[1,2,3]        => 1       }, #!!
      { Proc.as_is[nil]          => nil     },
      { Proc.as_is[true]         => true    },
      { Proc.as_is[false]        => false   },
    ]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'test/unit'
require 'gmrw/extension/array'

class TestFields < Test::Unit::TestCase
  def try_assert_equal(tests)
    tests.each_with_index do |test, i|
      actual, expected = test.first
      assert_equal(expected, actual, "case##{i}")
    end
  end

  def test_to_hash
    try_assert_equal [
      { [:a, 1       ].to_hash        => {:a => 1}          },
      { [:a, 1, :b, 2].to_hash        => {:a => 1, :b => 2} },

      { [[:a, 1]].to_hash             => {:a => 1}          },
      { [[:a, 1], [:b, 2]].to_hash    => {:a => 1, :b => 2} },

      { [[[:a, 1], [:b, 2]]].to_hash  => {[:a,1] => [:b,2]} },

      { [].to_hash                    => {}                 },
    ]
  end

  def test_cons
    try_assert_equal [
      { [1,2,3].cons(5)      => [5, 1, 2, 3] },
      { [1,2,3].cons(5,6)    => [5, 6, 1, 2, 3] },
      { [1,2,3].cons([5])    => [[5], 1, 2, 3] },
      { [1,2,3].cons([5,6])  => [[5,6], 1, 2, 3] },
      { [1,2,3].cons         => [1, 2, 3] },
    ]
  end

  def test_rjust
    try_assert_equal [
      { [1,2,3].rjust(5)      => [nil, nil, 1, 2, 3] },
      { [1,2,3].rjust(7)      => [nil, nil, nil, nil, 1, 2, 3] },
      { [1,2,3].rjust(3)      => [1, 2, 3] },
      { [1,2,3].rjust(2)      => [1, 2, 3] },
      { [1,2,3].rjust(0)      => [1, 2, 3] },

      { [1,2,3].rjust(5,0)    => [0, 0, 1, 2, 3] },
      { [1,2,3].rjust(7,0)    => [0, 0, 0, 0, 1, 2, 3] },
      { [1,2,3].rjust(3,0)    => [1, 2, 3] },
      { [1,2,3].rjust(2,0)    => [1, 2, 3] },
      { [1,2,3].rjust(0,0)    => [1, 2, 3] },
    ]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

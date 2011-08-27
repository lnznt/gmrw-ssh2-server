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

  def test_mapping
    try_assert_equal [
      { [:a, :b, :c].mapping => {0 => :a, 1 => :b, 2 => :c} },
      { [:a].mapping         => {0 => :a} },

      { [:a, :b, :c].mapping(:foo,:bar,:baz) => {:foo => :a, :bar => :b, :baz => :c} },
      { [:a, :b, :c].mapping(:foo,:bar)      => {:foo => :a, :bar => :b} },
      { [:a, :b    ].mapping(:foo,:bar,:baz) => {:foo => :a, :bar => :b, :baz => nil} },

      { [].mapping                  => {} },
      { [].mapping(:foo,:bar,:baz)  => {:foo => nil, :bar => nil, :baz => nil} },
    ]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:
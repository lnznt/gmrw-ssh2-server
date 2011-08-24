# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'test/unit'
require 'gmrw/extension/integer'

class TestFields < Test::Unit::TestCase
  def try_assert_equal(tests)
    tests.each_with_index do |test, i|
      actual, expected = test.first
      assert_equal(expected, actual, "case##{i}")
    end
  end

  def test_align
    try_assert_equal [
      {  0.align(8)      =>  0 },

      {  1.align(8)      =>  8 },
      {  7.align(8)      =>  8 },
      {  8.align(8)      =>  8 },

      {  9.align(8)      => 16 },
      { 10.align(8)      => 16 },

      { 20.align(8)      => 24 },
    ]
  end

  def test_maximun
    try_assert_equal [
      {  0.maximum(8)    => 0 },
      {  1.maximum(8)    => 1 },
      {  7.maximum(8)    => 7 },
      {  8.maximum(8)    => 8 },

      {  9.maximum(8)    => 8 },
      { 10.maximum(8)    => 8 },
      { 20.maximum(8)    => 8 },

      { -1.maximum(8)    =>  -1 },
      { -10.maximum(8)   => -10 },
    ]
  end

  def test_minimun
    try_assert_equal [
      {  0.minimum(8)    =>  8 },
      {  1.minimum(8)    =>  8 },
      {  8.minimum(8)    =>  8 },

      {  9.minimum(8)    =>  9 },
      { 10.minimum(8)    => 10 },
      { 20.minimum(8)    => 20 },

      { -1.minimum(8)    =>  8 },
      { -10.minimum(8)   =>  8 },
    ]
  end

  def test_count_bit
    try_assert_equal [
      {  0.count_bit    =>  0 },  # 0000b
      {  1.count_bit    =>  1 },  # 0001b
      {  2.count_bit    =>  1 },  # 0010b
      {  3.count_bit    =>  2 },  # 0011b
      {  4.count_bit    =>  1 },  # 0100b
      {  5.count_bit    =>  2 },  # 0101b
      {  6.count_bit    =>  2 },  # 0110b
      {  7.count_bit    =>  3 },  # 0111b
      {  8.count_bit    =>  1 },  # 1000b
    ]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

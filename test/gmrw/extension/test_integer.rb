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

  def test_bit_count
    try_assert_equal [
      {  0.bit.count    =>  0 },  # 0000b
      {  1.bit.count    =>  1 },  # 0001b
      {  2.bit.count    =>  1 },  # 0010b
      {  3.bit.count    =>  2 },  # 0011b
      {  4.bit.count    =>  1 },  # 0100b
      {  5.bit.count    =>  2 },  # 0101b
      {  6.bit.count    =>  2 },  # 0110b
      {  7.bit.count    =>  3 },  # 0111b
      {  8.bit.count    =>  1 },  # 1000b
    ]
  end

  def test_bit_range
    try_assert_equal [
      {  0.bit[7..0]    =>  0 },  # 0000b
      {  1.bit[7..0]    =>  1 },  # 0001b
      {  2.bit[7..0]    =>  2 },  # 0010b
      {  3.bit[7..0]    =>  3 },  # 0011b
      {  4.bit[7..0]    =>  4 },  # 0100b
      {  5.bit[7..0]    =>  5 },  # 0101b
      {  6.bit[7..0]    =>  6 },  # 0110b
      {  7.bit[7..0]    =>  7 },  # 0111b

      {  0.bit[0]    =>  0 },  # 0000b
      {  1.bit[0]    =>  1 },  # 0001b
      {  2.bit[0]    =>  0 },  # 0010b
      {  3.bit[0]    =>  1 },  # 0011b
      {  4.bit[0]    =>  0 },  # 0100b
      {  5.bit[0]    =>  1 },  # 0101b
      {  6.bit[0]    =>  0 },  # 0110b
      {  7.bit[0]    =>  1 },  # 0111b

      {  0.bit[1]    =>  0 },  # 0000b
      {  1.bit[1]    =>  0 },  # 0001b
      {  2.bit[1]    =>  1 },  # 0010b
      {  3.bit[1]    =>  1 },  # 0011b
      {  4.bit[1]    =>  0 },  # 0100b
      {  5.bit[1]    =>  0 },  # 0101b
      {  6.bit[1]    =>  1 },  # 0110b
      {  7.bit[1]    =>  1 },  # 0111b

      {  0.bit[1..0] =>  0 },  # 0000b
      {  1.bit[1..0] =>  1 },  # 0001b
      {  2.bit[1..0] =>  2 },  # 0010b
      {  3.bit[1..0] =>  3 },  # 0011b
      {  4.bit[1..0] =>  0 },  # 0100b
      {  5.bit[1..0] =>  1 },  # 0101b
      {  6.bit[1..0] =>  2 },  # 0110b
      {  7.bit[1..0] =>  3 },  # 0111b

      {  0.bit[3..1] =>  0 },  # 0000b
      {  1.bit[3..1] =>  0 },  # 0001b
      {  2.bit[3..1] =>  1 },  # 0010b
      {  3.bit[3..1] =>  1 },  # 0011b
      {  4.bit[3..1] =>  2 },  # 0100b
      {  5.bit[3..1] =>  2 },  # 0101b
      {  6.bit[3..1] =>  3 },  # 0110b
      {  7.bit[3..1] =>  3 },  # 0111b
    ]
  end

  def test_bit_div
    try_assert_equal [
      {  0.bit.div(1)      =>  [0]          },
      {  6.bit.div(1)      =>  [1, 1, 0]    },
      {  0x12.bit.div(8)   =>  [0x12]       },
      {  0x1234.bit.div(8) =>  [0x12, 0x34] },
      {  0x1234.bit.div(4) =>  [1, 2, 3, 4] },
      {  0x1234567890123456.bit.div(8)  =>  [0x12, 0x34, 0x56, 0x78, 0x90, 0x12, 0x34, 0x56] },
      {  0x1234567890123456.bit.div(32) =>  [0x12345678, 0x90123456] },
    ]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

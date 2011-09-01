# -*- coding: utf-8 -*- #
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

  def test_negative?
    try_assert_equal [
      { -1.negative?   =>  true },
      {  0.negative?   =>  false },
      {  1.negative?   =>  false },
    ]
  end

  def test_posive?
    try_assert_equal [
      {  1.positive?   =>  true },
      {  0.positive?   =>  false },
      { -1.positive?   =>  false },
    ]
  end

  def test_signum
    try_assert_equal [
      {  1.signum   =>   1 },
      {  0.signum   =>   0 },
      { -1.signum   =>  -1 },

      {  100.signum =>   1 },
      {  200.signum =>   1 },
      { -100.signum =>  -1 },
      { -200.signum =>  -1 },
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

      {  -1.bit.count    =>  -1 },  # .... ...1b(complement) # 0xFF
      {  -2.bit.count    =>  -1 },  # .... ..10b(complement) # 0xFE
      {  -3.bit.count    =>  -2 },  # .... .101b(complement) # 0xFD
      {  -4.bit.count    =>  -1 },  # .... .100b(complement) # 0xFC
      {  -5.bit.count    =>  -3 },  # .... 1011b(complement) # 0xFB
      {  -6.bit.count    =>  -2 },  # .... 1010b(complement) # 0xFA
      {  -7.bit.count    =>  -2 },  # .... 1001b(complement) # 0xF9
      {  -8.bit.count    =>  -1 },  # .... 1000b(complement) # 0xF8
    ]
  end

  def test_bit_wise
    try_assert_equal [
      {  0.bit.wise    =>  0 },  # 0000b
      {  1.bit.wise    =>  1 },  # 0001b
      {  2.bit.wise    =>  2 },  # 0010b
      {  3.bit.wise    =>  2 },  # 0011b
      {  4.bit.wise    =>  3 },  # 0100b
      {  5.bit.wise    =>  3 },  # 0101b
      {  6.bit.wise    =>  3 },  # 0110b
      {  7.bit.wise    =>  3 },  # 0111b
      {  8.bit.wise    =>  4 },  # 1000b

      { 0xff.bit.wise  =>  8 },  # 11111111b

      {  -1.bit.wise   =>  -1 },  # .... ...1b(complement) # 0xFF
      {  -2.bit.wise   =>  -2 },  # .... ..10b(complement) # 0xFE
      {  -3.bit.wise   =>  -3 },  # .... .101b(complement) # 0xFD
      {  -4.bit.wise   =>  -3 },  # .... .100b(complement) # 0xFC
      {  -5.bit.wise   =>  -4 },  # .... 1011b(complement) # 0xFB
      {  -6.bit.wise   =>  -4 },  # .... 1010b(complement) # 0xFA
      {  -7.bit.wise   =>  -4 },  # .... 1001b(complement) # 0xF9
      {  -8.bit.wise   =>  -4 },  # .... 1000b(complement) # 0xF8
    ]
  end

  def test_bit_mask
    try_assert_equal [
      {  4.bit.mask    => 0xf  },
      {  8.bit.mask    => 0xff },
      { 16.bit.mask    => 0xffff },
      { 32.bit.mask    => 0xffff_ffff },
    ]
  end

  def test_bit_msb?
    try_assert_equal [
      { 0x00.bit.msb?   => false },
      { 0x01.bit.msb?   => false },
      { 0x03.bit.msb?   => false },
      { 0x10.bit.msb?   => false },
      { 0x80.bit.msb?   => true },
      { 0xff.bit.msb?   => true },

      { 0x0.bit.msb?(4)  => false },
      { 0x1.bit.msb?(4)  => false },
      { 0x3.bit.msb?(4)  => false },
      { 0x7.bit.msb?(4)  => false },
      { 0x8.bit.msb?(4)  => true },
      { 0xf.bit.msb?(4)  => true },

      { 0x10.bit.msb?(4)  => false }, # bit.wise > bits
      { 0x80.bit.msb?(4)  => false }, # bit.wise > bits
      { 0xff.bit.msb?(4)  => false }, # bit.wise > bits
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
      {  0.bit.div(1)      =>  []           },
      {  0.bit.div(8)      =>  []           },
      {  0.bit.div         =>  []           },

      {  6.bit.div(1)               =>  [0, 1, 1, 0] },
      {  6.bit.div(1,:nolead=>true) =>  [   1, 1, 0] },

      {  0x12.bit.div(8)   =>  [0x12]       },
      {  0x12.bit.div      =>  [0x12]       },
      {  0x1234.bit.div(8) =>  [0x12, 0x34] },
      {  0x1234.bit.div    =>  [0x12, 0x34] },
      {  0x1234.bit.div(4) =>  [1, 2, 3, 4] },
      {  0x1234567890123456.bit.div(8)  =>  [0x12, 0x34, 0x56, 0x78, 0x90, 0x12, 0x34, 0x56] },
      {  0x1234567890123456.bit.div(32) =>  [0x12345678, 0x90123456] },

      {  -6.bit.div(1)      =>  [1, 0, 1, 0]    },
      {  -6.bit.div(8)      =>  [0xfa]          },
      {  -6.bit.div         =>  [0xfa]          },
      {  -1.bit.div(8)      =>  [0xff]          },
      {  -255.bit.div(8)    =>  [0xff, 0x01]    },

      {  0.bit.div(8)       =>  [] },
      {  0x1234.bit.div(8)  =>  [0x12, 0x34] },
      {  -0x1234.bit.div(8) =>  [0xed, 0xcc] },
      {  0x8000.bit.div(8)  =>  [0x00, 0x80, 0x00] },
      { -0xbeef.bit.div(8)  =>  [0xff, 0x41, 0x11] },
    ]
  end

  def test_bit_complement
    try_assert_equal [
      {  0.bit.complement(1)  =>  1            },
      {  0.bit.complement(8)  =>  0xff         },
      {  0.bit.complement     =>  0xff         },
      {  0.bit.complement(4)  =>  0xf          },
      {  0.bit.complement(6)  =>  0x3f         },
      {  0.bit.complement(16) =>  0xffff       },
      {  0.bit.complement(64) =>  0xffff_ffff_ffff_ffff },

      {  1.bit.complement(1)  =>  0 },
      {  1.bit.complement(64) =>  0xffff_ffff_ffff_fffe },

      {  0x12.bit.complement(8)  =>  0xed },
      {  0x12.bit.complement     =>  0xed },
    ]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

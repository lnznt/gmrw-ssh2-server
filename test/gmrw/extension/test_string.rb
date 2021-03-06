# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'test/unit'
require 'gmrw/extension/string'

class TestFields < Test::Unit::TestCase
  def try_assert_equal(tests)
    tests.each_with_index do |test, i|
      actual, expected = test.first
      assert_equal(expected, actual, "case##{i}")
    end
  end

  def test_indent
    try_assert_equal [
      { "foo" >> 1                  =>  " foo"        },
      { "foo" >> 4                  =>  "    foo"     },
      { "foo".indent(4, "-")        =>  "----foo"     },
      { "foo".indent(3, "->")       =>  "->->->foo"   },
    ]
  end

  def test_div
    try_assert_equal [
      { "foobar" / 1                =>  ["f","oobar"]  },
      { "foobar" / 2                =>  ["fo","obar"]  },
      { "foobar" / 5                =>  ["fooba","r"]  },
      { "foobar" / 6                =>  ["foobar",""]  },
      { "foobar" / 7                =>  ["foobar",nil] },
      { "foobar" / 0                =>  ["","foobar"]  },

      { "foobar".div                =>  ["f","oobar"]  },
      { "foobar".div(1)             =>  ["f","oobar"]  },
      { "foobar".div(2)             =>  ["fo","obar"]  },
      { "foobar".div(0)             =>  ["","foobar"]  },

      { "" / 1                      =>  ["",nil]       },
      { "" / 3                      =>  ["",nil]       },
      { "" / 0                      =>  ["",""]        },
    ]
  end

  def test_to_packet
    try_assert_equal [
      { "hello".to_packet           =>  [5, "hello"].pack("Na*")    },
      { "hello".to_packet(:uint32)  =>  [5, "hello"].pack("Na*")    },
      { "hello".to_packet(:none)    =>  "hello"                     },
      { "hello".to_packet(:uint8)   =>  [5, "hello"].pack("Ca*")    },
      { "hello".to_packet(:uint64)  =>  [0,5, "hello"].pack("NNa*") },
    ]
  end

  def test_to_bin_to_i
    try_assert_equal [
      { "".to_bin.to_i                           =>  0      },
      { [0x1].pack("C*").to_bin.to_i             =>  0x1    },
      { [0x12].pack("C*").to_bin.to_i            =>  0x12   },
      { [0x12,0x34].pack("C*").to_bin.to_i       =>  0x1234 },
      { [0xed,0xcc].pack("C*").to_bin.to_i       => -0x1234 },
      { [0x00,0x80,0x00].pack("C*").to_bin.to_i  =>  0x8000 },
      { [0xff,0x41,0x11].pack("C*").to_bin.to_i  => -0xbeef },
    ]
  end

  def test_to_bytes
    try_assert_equal [
      { "".to_bytes     =>  []                },
      { "ABC".to_bytes  =>  [0x41,0x42,0x43]  },
    ]
  end

  def test_to_bin
    try_assert_equal [
      { "".to_bin     =>  [].pack("C*")                },
      { "ABC".to_bin  =>  [0x41,0x42,0x43].pack("C*")  },
    ]
  end

  def test_to_BN
    try_assert_equal [
      { "10".to_BN                           =>  10  },
      { "10".to_BN(:dec)                     =>  10  },
      { "10".to_BN(:decimal)                 =>  10  },
      { "10".to_BN(10)                       =>  10  },
      { "10".to_BN(:hex)                     =>  16  },
      { "10".to_BN(:hexadecimal)             =>  16  },
      { "10".to_BN(16)                       =>  16  },
      { "\x10".to_BN(:bin)                   =>  16  },
      { "\x10".to_BN(:binary)                =>  16  },
      { "\x10".to_BN(2)                      =>  16  },
      { "\x00\x00\x00\x01\x10".to_BN(:mpi)   =>  16  },
      { "\x00\x00\x00\x01\x10".to_BN(:mpint) =>  16  },
      { "\x00\x00\x00\x01\x10".to_BN(0)      =>  16  },
      { "\x00\x00\x00\x00".to_BN(:mpi)       =>  0   },
    ]
  end

end

# vim:set ts=2 sw=2 et fenc=utf-8:

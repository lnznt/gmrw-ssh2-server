# -*- coding: ascii -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'test/unit'
require 'gmrw/extension/all'
require 'gmrw/ssh2/message/field'

class TestField < Test::Unit::TestCase
  include GMRW::SSH2::Message

  def try_assert_equal(tests)
    tests.each_with_index do |test, i|
      actual, expected = test.first
      assert_equal(expected, actual, "case##{i}")
    end
  end

  def test_default
    try_assert_equal [
      { Field.default(:boolean)   =>  false   },
      { Field.default(:byte)      =>  0       },
      { Field.default(:uint32)    =>  0       },
      { Field.default(:uint64)    =>  0       },
      { Field.default(:mpint)     =>  0       },
      { Field.default(:string)    =>  ""      },
      { Field.default(:namelist)  =>  []      },
      { Field.default(1)          =>  [0]     },
      { Field.default(4)          =>  [0] * 4 },

      { Field.default(1.0)        =>  nil     },
      { Field.default(:xxx)       =>  nil     },
      { Field.default(nil)        =>  nil     },
    ]
  end

  def test_validate__boolean
    try_assert_equal [
      { Field.validate(:boolean, false) => true    },
      { Field.validate(:boolean, true)  => true    },

      { Field.validate(:boolean, nil)   => false   },
      { Field.validate(:boolean, 0)     => false   },
      { Field.validate(:boolean, "")    => false   },
    ]
  end

  def test_validate__byte
    try_assert_equal [
      { Field.validate(:byte, 0x00)  => true    },
      { Field.validate(:byte, 0x01)  => true    },
      { Field.validate(:byte, 0xff)  => true    },

      { Field.validate(:byte, nil)   => false   },
      { Field.validate(:byte, -1)    => false   },
      { Field.validate(:byte, 1.0)   => false   },
      { Field.validate(:byte, 0x100) => false   },
      { Field.validate(:byte, "1")   => false   },
    ]
  end

  def test_validate__uint32
    try_assert_equal [
      { Field.validate(:uint32, 0x00)          => true    },
      { Field.validate(:uint32, 0x01)          => true    },
      { Field.validate(:uint32, 0xffff_ffff)   => true    },

      { Field.validate(:uint32, nil)           => false   },
      { Field.validate(:uint32, -1)            => false   },
      { Field.validate(:uint32, 1.0)           => false   },
      { Field.validate(:uint32, 0x1_0000_0000) => false   },
      { Field.validate(:uint32, "1")           => false   },
    ]
  end

  def test_validate__uint64
    try_assert_equal [
      { Field.validate(:uint64, 0x00)          => true    },
      { Field.validate(:uint64, 0x01)          => true    },
      { Field.validate(:uint64, (1 << 64) - 1) => true    },

      { Field.validate(:uint64, nil)           => false   },
      { Field.validate(:uint64, -1)            => false   },
      { Field.validate(:uint64, 1.0)           => false   },
      { Field.validate(:uint64, (1 << 64))     => false   },
      { Field.validate(:uint64, "1")           => false   },
    ]
  end

  def test_validate__mpint
    try_assert_equal [
      { Field.validate(:mpint, 0x00.to_bignum)          => true    },
      { Field.validate(:mpint, 0x01.to_bignum)          => true    },
      { Field.validate(:mpint, (1 << 64).to_bignum)     => true    },
      { Field.validate(:mpint, -1.to_bignum)            => true    },

      { Field.validate(:mpint, 0)             => false   },
      { Field.validate(:mpint, 1)             => false   },
      { Field.validate(:mpint, nil)           => false   },
      { Field.validate(:mpint, 1.0)           => false   },
      { Field.validate(:mpint, "1")           => false   },
    ]
  end

  def test_validate__string
    try_assert_equal [
      { Field.validate(:string, "ABC")        => true    },
      { Field.validate(:string, "")           => true    },

      { Field.validate(:string, nil)          => false   },
      { Field.validate(:string, :abc)         => false   },
      { Field.validate(:string, 1)            => false   },
    ]
  end

  def test_validate__namelist
    try_assert_equal [
      { Field.validate(:namelist, ["abc","def","ghi"]) => true    },
      { Field.validate(:namelist, ["abc"])             => true    },
      { Field.validate(:namelist, ["abc","def","a@b"]) => true    },
      { Field.validate(:namelist, ["a@c"])             => true    },
      { Field.validate(:namelist, ["a@c","d@f","a@b"]) => true    },
      { Field.validate(:namelist, ["a" * 64])          => true    },
      { Field.validate(:namelist, ["a" * 64, "b" * 64])=> true    },
      { Field.validate(:namelist, [])                  => true    },

      { Field.validate(:namelist, ["abc","def","a\n"]) => false   },
      { Field.validate(:namelist, ["abc","def","a\t"]) => false   },
      { Field.validate(:namelist, ["abc","a\nb"])      => false   },
      { Field.validate(:namelist, ["abc","a\tb"])      => false   },
      { Field.validate(:namelist, ["abc","\nb"])       => false   },
      { Field.validate(:namelist, ["abc","\tb"])       => false   },
      { Field.validate(:namelist, ["abc","a\x1fb"])    => false   },
      { Field.validate(:namelist, ["abc","a\x7fb"])    => false   },
      { Field.validate(:namelist, ["abc","a\x80b"])    => false   },
      { Field.validate(:namelist, ["abc","def","a@"])  => false   },
      { Field.validate(:namelist, ["abc","def","@a"])  => false   },
      { Field.validate(:namelist, ["abc","a@b@c"])     => false   },
      { Field.validate(:namelist, ["abc","@b@c"])      => false   },
      { Field.validate(:namelist, ["abc","a@b@"])      => false   },
      { Field.validate(:namelist, ["abc","@"])         => false   },
      { Field.validate(:namelist, ["abc,def","ghi"])   => false   },
      { Field.validate(:namelist, [",def","ghi"])      => false   },
      { Field.validate(:namelist, ["def,","ghi"])      => false   },
      { Field.validate(:namelist, ["abc def","ghi"])   => false   },
      { Field.validate(:namelist, [" def","ghi"])      => false   },
      { Field.validate(:namelist, ["def ","ghi"])      => false   },
      { Field.validate(:namelist, ["a" * 65])          => false   },
      { Field.validate(:namelist, ["a" * 65, "b","c"]) => false   },
      { Field.validate(:namelist, [""])                => false   },
      { Field.validate(:namelist, ["abc","def",""])    => false   },

      { Field.validate(:namelist, ["a@c","def",:ghi])  => false   },
      { Field.validate(:namelist, ["abc","def",nil])   => false   },
      { Field.validate(:namelist, ["abc","def",:ghi])  => false   },
      { Field.validate(:namelist, [nil])               => false   },
      { Field.validate(:namelist, :abc)                => false   },
      { Field.validate(:namelist, 1)                   => false   },
    ]
  end

  def test_validate__bytes
    try_assert_equal [
      { Field.validate(4, [0x00,0x00,0x00,0x00])   => true    },
      { Field.validate(4, [0x01,0x01,0x01,0x01])   => true    },
      { Field.validate(4, [0xff,0xff,0xff,0xff])   => true    },
      { Field.validate(4, [0x01,0x02,0x03,0xff])   => true    },
      { Field.validate(1, [0x00])                  => true    },
      { Field.validate(1, [0xff])                  => true    },

      { Field.validate(1, [nil])                   => false   },
      { Field.validate(2, [0x00, 0x100])           => false   },
      { Field.validate(2, [0x00, -1])              => false   },
      { Field.validate(2, [0x00, 1.0])             => false   },
      { Field.validate(2, [0x00, nil])             => false   },
      { Field.validate(2, [0x00, "1"])             => false   },

      { Field.validate(1, [0x00, 0x00])            => false   },
      { Field.validate(3, [0x00, 0x00])            => false   },
    ]
  end

  def test_decode__byte
    try_assert_equal [
      { Field.decode(:byte, "\x00")     => [0x00, ""]    },
      { Field.decode(:byte, "\x01")     => [0x01, ""]    },
      { Field.decode(:byte, "\xff")     => [0xff, ""]    },

      { Field.decode(:byte, "\x00ABC")  => [0x00, "ABC"] },
      { Field.decode(:byte, "\x01ABC")  => [0x01, "ABC"] },
      { Field.decode(:byte, "\xffABC")  => [0xff, "ABC"] },

      { Field.decode(:byte, "")         => nil },
    ]
  end

  def test_decode__boolean
    try_assert_equal [
      { Field.decode(:boolean, "\x00")     => [false, ""]    },
      { Field.decode(:boolean, "\x01")     => [true,  ""]    },
      { Field.decode(:boolean, "\xff")     => [true,  ""]    },

      { Field.decode(:boolean, "\x00ABC")  => [false, "ABC"] },
      { Field.decode(:boolean, "\x01ABC")  => [true,  "ABC"] },
      { Field.decode(:boolean, "\xffABC")  => [true,  "ABC"] },

      { Field.decode(:boolean, "")         => nil },
    ]
  end

  def test_decode__uint32
    try_assert_equal [
      { Field.decode(:uint32, "\x00\x00\x00\x00")  => [          0, ""] },
      { Field.decode(:uint32, "\x00\x00\x00\x01")  => [          1, ""] },
      { Field.decode(:uint32, "\xff\xff\xff\xff")  => [0xffff_ffff, ""] },

      { Field.decode(:uint32, "\x00\x00\x00\x00A") => [          0, "A"] },

      { Field.decode(:uint32, "")                  => nil },
      { Field.decode(:uint32, "\x00\x00\x00")      => nil },
    ]
  end

  def test_decode__uint64
    try_assert_equal [
      { Field.decode(:uint64, "\x00\x00\x00\x00" +
                               "\x00\x00\x00\x00")  => [          0, ""] },
      { Field.decode(:uint64, "\x00\x00\x00\x00" +
                               "\x00\x00\x00\x01")  => [          1, ""] },
      { Field.decode(:uint64, "\x12\x34\x56\x78" +
                               "\x9a\xbc\xde\xf0")  => [0x1234_5678_9abc_def0, ""] },
      { Field.decode(:uint64, "\xff\xff\xff\xff" +
                               "\xff\xff\xff\xff")  => [0xffff_ffff_ffff_ffff, ""] },

      { Field.decode(:uint64, "\x00\x00\x00\x00" +
                               "\x00\x00\x00\x01A")  => [          1, "A"] },

      { Field.decode(:uint64, "")                  => nil },
      { Field.decode(:uint64, "\x00\x00\x00\x00" +
                               "\x00\x00\x00")      => nil },
    ]
  end

  def test_decode__string
    try_assert_equal [
      { Field.decode(:string, "\x00\x00\x00\x00")     => ["",     ""]  },
      { Field.decode(:string, "\x00\x00\x00\x03ABC")  => ["ABC",  ""]  },
      { Field.decode(:string, "\x00\x00\x00\x03ABCD") => ["ABC",  "D"] },

      { Field.decode(:string, "")                     => nil },
      { Field.decode(:string, "\x00\x00\x00")         => nil },
      { Field.decode(:string, "\x00\x00\x00\x03AB")   => nil },
    ]
  end

  def test_decode__namelist
    try_assert_equal [
      { Field.decode(:namelist, "\x00\x00\x00\x00")     => [[],        ""]  },
      { Field.decode(:namelist, "\x00\x00\x00\x03ABC")  => [["ABC"],   ""]  },
      { Field.decode(:namelist, "\x00\x00\x00\x03ABCD") => [["ABC"],   "D"] },
      { Field.decode(:namelist, "\x00\x00\x00\x03A,C")  => [["A","C"], ""]  },
      { Field.decode(:namelist, "\x00\x00\x00\x03A,CD") => [["A","C"], "D"] },

      { Field.decode(:namelist, "")                     => nil },
      { Field.decode(:namelist, "\x00\x00\x00")         => nil },
      { Field.decode(:namelist, "\x00\x00\x00\x04A,C")  => nil },
    ]
  end

  def test_decode__mpint
    try_assert_equal [
      { Field.decode(:mpint, "\x00\x00\x00\x00") => [0,  ""]  },

      { Field.decode(:mpint, "\x00\x00\x00\x02\x12\x34") => [0x1234,  ""]  },
      { Field.decode(:mpint, "\x00\x00\x00\x02\xed\xcc") => [-0x1234, ""]  },

      { Field.decode(:mpint, "\x00\x00\x00\x03\x00\x80\x00") => [0x8000,  ""]  },
      { Field.decode(:mpint, "\x00\x00\x00\x03\xff\x41\x11") => [-0xbeef, ""]  },

      { Field.decode(:mpint, "\x00\x00\x00\x02\x12\x34A") => [0x1234,  "A"]  },
      { Field.decode(:mpint, "\x00\x00\x00\x02\xed\xccA") => [-0x1234, "A"]  },

      { Field.decode(:mpint, "\x00\x00\x00\x03\x00\x80\x00A") => [0x8000,  "A"]  },
      { Field.decode(:mpint, "\x00\x00\x00\x03\xff\x41\x11A") => [-0xbeef, "A"]  },


      { Field.decode(:mpint, "")                           => nil },
      { Field.decode(:mpint, "\x00\x00\x00")               => nil },
      { Field.decode(:mpint, "\x00\x00\x00\x03\x12\x34")   => nil },
    ]
  end

  def test_decode__bytes
    try_assert_equal [
      { Field.decode(4, "\x00\x00\x00\x00") => [[0x00]*4,  ""]  },
      { Field.decode(4, "\xff\xff\xff\xff") => [[0xff]*4,  ""]  },
      { Field.decode(4, "\x12\x34\x56\x78") => [[0x12,0x34,0x56,0x78],  ""]  },

      { Field.decode(1, "\x00")    => [[0x00],  ""]  },
      { Field.decode(1, "\xff")    => [[0xff],  ""]  },
      { Field.decode(1, "\x00ABC") => [[0x00],  "ABC"]  },
      { Field.decode(1, "\xffABC") => [[0xff],  "ABC"]  },

      { Field.decode(1, "")              => nil  },
      { Field.decode(4, "\x00\x00\x00")  => nil  },
    ]
  end

  def test_encode__boolean
    try_assert_equal [
      { Field.encode(:boolean, true)    => "\x01"    },
      { Field.encode(:boolean, false)   => "\x00"    },
    ]
  end

  def test_encode__byte
    try_assert_equal [
      { Field.encode(:byte, 0x00)   => [0x00].pack("C") },
      { Field.encode(:byte, 0x01)   => [0x01].pack("C") },
      { Field.encode(:byte, 0xff)   => [0xff].pack("C") },
    ]
  end

  def test_encode__uint32
    try_assert_equal [
      { Field.encode(:uint32, 0x00)        => [0x00].pack("N") },
      { Field.encode(:uint32, 0x01)        => [0x01].pack("N") },
      { Field.encode(:uint32, 0xffff_ffff) => [0xffff_ffff].pack("N") },
    ]
  end

  def test_encode__uint64
    try_assert_equal [
      { Field.encode(:uint64, 0x00)                  => [0x00].pack("N") + [0x00].pack("N") },
      { Field.encode(:uint64, 0x01)                  => [0x00].pack("N") + [0x01].pack("N") },
      { Field.encode(:uint64, 0xffff_ffff_ffff_ffff) => [0xffff_ffff].pack("N") * 2 },
    ]
  end

  def test_encode__string
    try_assert_equal [
      { Field.encode(:string, "")     => [0].pack("N")         },
      { Field.encode(:string, "ABC")  => [3].pack("N") + "ABC" },
    ]
  end

  def test_encode__namelist
    try_assert_equal [
      { Field.encode(:namelist, [])            => [0].pack("N")              },
      { Field.encode(:namelist, ["ABC"])       => [3].pack("N") + "ABC"      },
      { Field.encode(:namelist, ["ABC","DEF"]) => [7].pack("N") + "ABC,DEF"  },
    ]
  end

  def test_encode__bytes
    try_assert_equal [
      { Field.encode(4, [0x12,0x34,0x56,0x78]) => [0x12,0x34,0x56,0x78].pack("C4") },
      { Field.encode(1, [0x00])                => [0x00].pack("C") },
      { Field.encode(1, [0xff])                => [0xff].pack("C") },
    ]
  end

  def test_encode__bytes
    try_assert_equal [
      { Field.encode(4, [0x12,0x34,0x56,0x78]) => [0x12,0x34,0x56,0x78].pack("C4") },
      { Field.encode(1, [0x00])                => [0x00].pack("C") },
      { Field.encode(1, [0xff])                => [0xff].pack("C") },
    ]
  end

  def test_encode__mpint
    try_assert_equal [
      { Field.encode(:mpint, 0) => [0].pack("N") },

      { Field.encode(:mpint,  0x1234) => [2].pack("N") + "\x12\x34" },
      { Field.encode(:mpint, -0x1234) => [2].pack("N") + "\xed\xcc" },

      { Field.encode(:mpint,  0x8000) => [3].pack("N") + "\x00\x80\x00" },
      { Field.encode(:mpint, -0xbeef) => [3].pack("N") + "\xff\x41\x11" },
    ]
  end

end

# vim:set ts=2 sw=2 et fenc=utf-8:

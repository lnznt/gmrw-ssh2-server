# -*- coding: ascii -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'test/unit'
require 'gmrw/ssh2/message/fields'

class TestFields < Test::Unit::TestCase
  include GMRW::SSH2::Message

  def try_assert_equal(tests)
    tests.each_with_index do |test, i|
      actual, expected = test.first
      assert_equal(expected, actual, "case##{i}")
    end
  end

  def test_default
    try_assert_equal [
      { Fields.default(:boolean)   =>  false   },
      { Fields.default(:byte)      =>  0       },
      { Fields.default(:uint32)    =>  0       },
      { Fields.default(:uint64)    =>  0       },
      { Fields.default(:mpint)     =>  0       },
      { Fields.default(:string)    =>  ""      },
      { Fields.default(:namelist)  =>  []      },
      { Fields.default(1)          =>  [0]     },
      { Fields.default(4)          =>  [0] * 4 },

      { Fields.default(1.0)        =>  nil     },
      { Fields.default(:xxx)       =>  nil     },
      { Fields.default(nil)        =>  nil     },
    ]
  end

  def test_validate__boolean
    try_assert_equal [
      { Fields.validate(:boolean, false) => true    },
      { Fields.validate(:boolean, true)  => true    },

      { Fields.validate(:boolean, nil)   => false   },
      { Fields.validate(:boolean, 0)     => false   },
      { Fields.validate(:boolean, "")    => false   },
    ]
  end

  def test_validate__byte
    try_assert_equal [
      { Fields.validate(:byte, 0x00)  => true    },
      { Fields.validate(:byte, 0x01)  => true    },
      { Fields.validate(:byte, 0xff)  => true    },

      { Fields.validate(:byte, nil)   => false   },
      { Fields.validate(:byte, -1)    => false   },
      { Fields.validate(:byte, 1.0)   => false   },
      { Fields.validate(:byte, 0x100) => false   },
      { Fields.validate(:byte, "1")   => false   },
    ]
  end

  def test_validate__uint32
    try_assert_equal [
      { Fields.validate(:uint32, 0x00)          => true    },
      { Fields.validate(:uint32, 0x01)          => true    },
      { Fields.validate(:uint32, 0xffff_ffff)   => true    },

      { Fields.validate(:uint32, nil)           => false   },
      { Fields.validate(:uint32, -1)            => false   },
      { Fields.validate(:uint32, 1.0)           => false   },
      { Fields.validate(:uint32, 0x1_0000_0000) => false   },
      { Fields.validate(:uint32, "1")           => false   },
    ]
  end

  def test_validate__uint64
    try_assert_equal [
      { Fields.validate(:uint64, 0x00)          => true    },
      { Fields.validate(:uint64, 0x01)          => true    },
      { Fields.validate(:uint64, (1 << 64) - 1) => true    },

      { Fields.validate(:uint64, nil)           => false   },
      { Fields.validate(:uint64, -1)            => false   },
      { Fields.validate(:uint64, 1.0)           => false   },
      { Fields.validate(:uint64, (1 << 64))     => false   },
      { Fields.validate(:uint64, "1")           => false   },
    ]
  end

  def test_validate__mpint
    try_assert_equal [
      { Fields.validate(:mpint, 0x00)          => true    },
      { Fields.validate(:mpint, 0x01)          => true    },
      { Fields.validate(:mpint, (1 << 64))     => true    },
      { Fields.validate(:mpint, -1)            => true    },

      { Fields.validate(:mpint, nil)           => false   },
      { Fields.validate(:mpint, 1.0)           => false   },
      { Fields.validate(:mpint, "1")           => false   },
    ]
  end

  def test_validate__string
    try_assert_equal [
      { Fields.validate(:string, "ABC")        => true    },
      { Fields.validate(:string, "")           => true    },

      { Fields.validate(:string, nil)          => false   },
      { Fields.validate(:string, :abc)         => false   },
      { Fields.validate(:string, 1)            => false   },
    ]
  end

  def test_validate__namelist
    try_assert_equal [
      { Fields.validate(:namelist, ["abc","def","ghi"]) => true    },
      { Fields.validate(:namelist, ["abc"])             => true    },
      { Fields.validate(:namelist, ["abc","def","a@b"]) => true    },
      { Fields.validate(:namelist, ["a@c"])             => true    },
      { Fields.validate(:namelist, ["a@c","d@f","a@b"]) => true    },
      { Fields.validate(:namelist, ["a" * 64])          => true    },
      { Fields.validate(:namelist, ["a" * 64, "b" * 64])=> true    },
      { Fields.validate(:namelist, [])                  => true    },

      { Fields.validate(:namelist, ["abc","def","a\n"]) => false   },
      { Fields.validate(:namelist, ["abc","def","a\t"]) => false   },
      { Fields.validate(:namelist, ["abc","a\nb"])      => false   },
      { Fields.validate(:namelist, ["abc","a\tb"])      => false   },
      { Fields.validate(:namelist, ["abc","\nb"])       => false   },
      { Fields.validate(:namelist, ["abc","\tb"])       => false   },
      { Fields.validate(:namelist, ["abc","a\x1fb"])    => false   },
      { Fields.validate(:namelist, ["abc","a\x7fb"])    => false   },
      { Fields.validate(:namelist, ["abc","a\x80b"])    => false   },
      { Fields.validate(:namelist, ["abc","def","a@"])  => false   },
      { Fields.validate(:namelist, ["abc","def","@a"])  => false   },
      { Fields.validate(:namelist, ["abc","a@b@c"])     => false   },
      { Fields.validate(:namelist, ["abc","@b@c"])      => false   },
      { Fields.validate(:namelist, ["abc","a@b@"])      => false   },
      { Fields.validate(:namelist, ["abc","@"])         => false   },
      { Fields.validate(:namelist, ["abc,def","ghi"])   => false   },
      { Fields.validate(:namelist, [",def","ghi"])      => false   },
      { Fields.validate(:namelist, ["def,","ghi"])      => false   },
      { Fields.validate(:namelist, ["abc def","ghi"])   => false   },
      { Fields.validate(:namelist, [" def","ghi"])      => false   },
      { Fields.validate(:namelist, ["def ","ghi"])      => false   },
      { Fields.validate(:namelist, ["a" * 65])          => false   },
      { Fields.validate(:namelist, ["a" * 65, "b","c"]) => false   },
      { Fields.validate(:namelist, [""])                => false   },
      { Fields.validate(:namelist, ["abc","def",""])    => false   },

      { Fields.validate(:namelist, ["a@c","def",:ghi])  => false   },
      { Fields.validate(:namelist, ["abc","def",nil])   => false   },
      { Fields.validate(:namelist, ["abc","def",:ghi])  => false   },
      { Fields.validate(:namelist, [nil])               => false   },
      { Fields.validate(:namelist, :abc)                => false   },
      { Fields.validate(:namelist, 1)                   => false   },
    ]
  end

  def test_validate__bytes
    try_assert_equal [
      { Fields.validate(4, [0x00,0x00,0x00,0x00])   => true    },
      { Fields.validate(4, [0x01,0x01,0x01,0x01])   => true    },
      { Fields.validate(4, [0xff,0xff,0xff,0xff])   => true    },
      { Fields.validate(4, [0x01,0x02,0x03,0xff])   => true    },
      { Fields.validate(1, [0x00])                  => true    },
      { Fields.validate(1, [0xff])                  => true    },

      { Fields.validate(1, [nil])                   => false   },
      { Fields.validate(2, [0x00, 0x100])           => false   },
      { Fields.validate(2, [0x00, -1])              => false   },
      { Fields.validate(2, [0x00, 1.0])             => false   },
      { Fields.validate(2, [0x00, nil])             => false   },
      { Fields.validate(2, [0x00, "1"])             => false   },

      { Fields.validate(1, [0x00, 0x00])            => false   },
      { Fields.validate(3, [0x00, 0x00])            => false   },
    ]
  end

  def test_decode__byte
    try_assert_equal [
      { Fields.decode(:byte, "\x00")     => [0x00, ""]    },
      { Fields.decode(:byte, "\x01")     => [0x01, ""]    },
      { Fields.decode(:byte, "\xff")     => [0xff, ""]    },

      { Fields.decode(:byte, "\x00ABC")  => [0x00, "ABC"] },
      { Fields.decode(:byte, "\x01ABC")  => [0x01, "ABC"] },
      { Fields.decode(:byte, "\xffABC")  => [0xff, "ABC"] },

      { Fields.decode(:byte, "")         => nil },
    ]
  end

  def test_decode__boolean
    try_assert_equal [
      { Fields.decode(:boolean, "\x00")     => [false, ""]    },
      { Fields.decode(:boolean, "\x01")     => [true,  ""]    },
      { Fields.decode(:boolean, "\xff")     => [true,  ""]    },

      { Fields.decode(:boolean, "\x00ABC")  => [false, "ABC"] },
      { Fields.decode(:boolean, "\x01ABC")  => [true,  "ABC"] },
      { Fields.decode(:boolean, "\xffABC")  => [true,  "ABC"] },

      { Fields.decode(:boolean, "")         => nil },
    ]
  end

  def test_decode__uint32
    try_assert_equal [
      { Fields.decode(:uint32, "\x00\x00\x00\x00")  => [          0, ""] },
      { Fields.decode(:uint32, "\x00\x00\x00\x01")  => [          1, ""] },
      { Fields.decode(:uint32, "\xff\xff\xff\xff")  => [0xffff_ffff, ""] },

      { Fields.decode(:uint32, "\x00\x00\x00\x00A") => [          0, "A"] },

      { Fields.decode(:uint32, "")                  => nil },
      { Fields.decode(:uint32, "\x00\x00\x00")      => nil },
    ]
  end

  def test_decode__uint64
    try_assert_equal [
      { Fields.decode(:uint64, "\x00\x00\x00\x00" +
                               "\x00\x00\x00\x00")  => [          0, ""] },
      { Fields.decode(:uint64, "\x00\x00\x00\x00" +
                               "\x00\x00\x00\x01")  => [          1, ""] },
      { Fields.decode(:uint64, "\x12\x34\x56\x78" +
                               "\x9a\xbc\xde\xf0")  => [0x1234_5678_9abc_def0, ""] },
      { Fields.decode(:uint64, "\xff\xff\xff\xff" +
                               "\xff\xff\xff\xff")  => [0xffff_ffff_ffff_ffff, ""] },

      { Fields.decode(:uint64, "\x00\x00\x00\x00" +
                               "\x00\x00\x00\x01A")  => [          1, "A"] },

      { Fields.decode(:uint64, "")                  => nil },
      { Fields.decode(:uint64, "\x00\x00\x00\x00" +
                               "\x00\x00\x00")      => nil },
    ]
  end

  def test_decode__string
    try_assert_equal [
      { Fields.decode(:string, "\x00\x00\x00\x00")     => ["",     ""]  },
      { Fields.decode(:string, "\x00\x00\x00\x03ABC")  => ["ABC",  ""]  },
      { Fields.decode(:string, "\x00\x00\x00\x03ABCD") => ["ABC",  "D"] },

      { Fields.decode(:string, "")                     => nil },
      { Fields.decode(:string, "\x00\x00\x00")         => nil },
      { Fields.decode(:string, "\x00\x00\x00\x03AB")   => nil },
    ]
  end

  def test_decode__namelist
    try_assert_equal [
      { Fields.decode(:namelist, "\x00\x00\x00\x00")     => [[],        ""]  },
      { Fields.decode(:namelist, "\x00\x00\x00\x03ABC")  => [["ABC"],   ""]  },
      { Fields.decode(:namelist, "\x00\x00\x00\x03ABCD") => [["ABC"],   "D"] },
      { Fields.decode(:namelist, "\x00\x00\x00\x03A,C")  => [["A","C"], ""]  },
      { Fields.decode(:namelist, "\x00\x00\x00\x03A,CD") => [["A","C"], "D"] },

      { Fields.decode(:namelist, "")                     => nil },
      { Fields.decode(:namelist, "\x00\x00\x00")         => nil },
      { Fields.decode(:namelist, "\x00\x00\x00\x04A,C")  => nil },
    ]
  end

  def test_decode__mpint
    try_assert_equal [
      { Fields.decode(:mpint, "\x00\x00\x00\x00") => [0,  ""]  },

      { Fields.decode(:mpint, "\x00\x00\x00\x02\x12\x34") => [0x1234,  ""]  },
      { Fields.decode(:mpint, "\x00\x00\x00\x02\xed\xcc") => [-0x1234, ""]  },

      { Fields.decode(:mpint, "\x00\x00\x00\x03\x00\x80\x00") => [0x8000,  ""]  },
      { Fields.decode(:mpint, "\x00\x00\x00\x03\xff\x41\x11") => [-0xbeef, ""]  },

      { Fields.decode(:mpint, "\x00\x00\x00\x02\x12\x34A") => [0x1234,  "A"]  },
      { Fields.decode(:mpint, "\x00\x00\x00\x02\xed\xccA") => [-0x1234, "A"]  },

      { Fields.decode(:mpint, "\x00\x00\x00\x03\x00\x80\x00A") => [0x8000,  "A"]  },
      { Fields.decode(:mpint, "\x00\x00\x00\x03\xff\x41\x11A") => [-0xbeef, "A"]  },


      { Fields.decode(:mpint, "")                           => nil },
      { Fields.decode(:mpint, "\x00\x00\x00")               => nil },
      { Fields.decode(:mpint, "\x00\x00\x00\x03\x12\x34")   => nil },
    ]
  end

  def test_decode__bytes
    try_assert_equal [
      { Fields.decode(4, "\x00\x00\x00\x00") => [[0x00]*4,  ""]  },
      { Fields.decode(4, "\xff\xff\xff\xff") => [[0xff]*4,  ""]  },
      { Fields.decode(4, "\x12\x34\x56\x78") => [[0x12,0x34,0x56,0x78],  ""]  },

      { Fields.decode(1, "\x00")    => [[0x00],  ""]  },
      { Fields.decode(1, "\xff")    => [[0xff],  ""]  },
      { Fields.decode(1, "\x00ABC") => [[0x00],  "ABC"]  },
      { Fields.decode(1, "\xffABC") => [[0xff],  "ABC"]  },

      { Fields.decode(1, "")              => nil  },
      { Fields.decode(4, "\x00\x00\x00")  => nil  },
    ]
  end

  def test_encode__boolean
    try_assert_equal [
      { Fields.encode(:boolean, true)    => "\x01"    },
      { Fields.encode(:boolean, false)   => "\x00"    },
    ]
  end

  def test_encode__byte
    try_assert_equal [
      { Fields.encode(:byte, 0x00)   => [0x00].pack("C") },
      { Fields.encode(:byte, 0x01)   => [0x01].pack("C") },
      { Fields.encode(:byte, 0xff)   => [0xff].pack("C") },
    ]
  end

  def test_encode__uint32
    try_assert_equal [
      { Fields.encode(:uint32, 0x00)        => [0x00].pack("N") },
      { Fields.encode(:uint32, 0x01)        => [0x01].pack("N") },
      { Fields.encode(:uint32, 0xffff_ffff) => [0xffff_ffff].pack("N") },
    ]
  end

  def test_encode__uint64
    try_assert_equal [
      { Fields.encode(:uint64, 0x00)                  => [0x00].pack("N") + [0x00].pack("N") },
      { Fields.encode(:uint64, 0x01)                  => [0x00].pack("N") + [0x01].pack("N") },
      { Fields.encode(:uint64, 0xffff_ffff_ffff_ffff) => [0xffff_ffff].pack("N") * 2 },
    ]
  end

  def test_encode__string
    try_assert_equal [
      { Fields.encode(:string, "")     => [0].pack("N")         },
      { Fields.encode(:string, "ABC")  => [3].pack("N") + "ABC" },
    ]
  end

  def test_encode__namelist
    try_assert_equal [
      { Fields.encode(:namelist, [])            => [0].pack("N")              },
      { Fields.encode(:namelist, ["ABC"])       => [3].pack("N") + "ABC"      },
      { Fields.encode(:namelist, ["ABC","DEF"]) => [7].pack("N") + "ABC,DEF"  },
    ]
  end

  def test_encode__bytes
    try_assert_equal [
      { Fields.encode(4, [0x12,0x34,0x56,0x78]) => [0x12,0x34,0x56,0x78].pack("C4") },
      { Fields.encode(1, [0x00])                => [0x00].pack("C") },
      { Fields.encode(1, [0xff])                => [0xff].pack("C") },
    ]
  end

  def test_encode__bytes
    try_assert_equal [
      { Fields.encode(4, [0x12,0x34,0x56,0x78]) => [0x12,0x34,0x56,0x78].pack("C4") },
      { Fields.encode(1, [0x00])                => [0x00].pack("C") },
      { Fields.encode(1, [0xff])                => [0xff].pack("C") },
    ]
  end

  def test_encode__mpint
    try_assert_equal [
      { Fields.encode(:mpint, 0) => [0].pack("N") },

      { Fields.encode(:mpint,  0x1234) => [2].pack("N") + "\x12\x34" },
      { Fields.encode(:mpint, -0x1234) => [2].pack("N") + "\xed\xcc" },

      { Fields.encode(:mpint,  0x8000) => [3].pack("N") + "\x00\x80\x00" },
      { Fields.encode(:mpint, -0xbeef) => [3].pack("N") + "\xff\x41\x11" },
    ]
  end

end

# vim:set ts=2 sw=2 et fenc=utf-8:

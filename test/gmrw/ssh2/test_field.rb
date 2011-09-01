# -*- coding: ascii -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'test/unit'
require 'openssl'
require 'gmrw/ssh2/field'

class TestField < Test::Unit::TestCase
  include GMRW::SSH2

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
      { Field.default(:mpint)     =>  OpenSSL::BN.new(0.to_s) },
      { Field.default(:string)    =>  ""      },
      { Field.default(:namelist)  =>  []      },
      { Field.default(1)          =>  [0]     },
      { Field.default(4)          =>  [0] * 4 },

      { Field.default(0)          =>  nil     },
      { Field.default(1.0)        =>  nil     },
      { Field.default(:xxx)       =>  nil     },
      { Field.default("")         =>  nil     },
      { Field.default(true)       =>  nil     },
      { Field.default(false)      =>  nil     },
      { Field.default(nil)        =>  nil     },
    ]
  end
  def test_field_size
    try_assert_equal [
      { Field.field_size(:boolean)   =>  1       },
      { Field.field_size(:byte)      =>  1       },
      { Field.field_size(:uint32)    =>  4       },
      { Field.field_size(:uint64)    =>  8       },
      { Field.field_size(:mpint)     =>  nil     },
      { Field.field_size(:string)    =>  nil     },
      { Field.field_size(:namelist)  =>  nil     },
      { Field.field_size(1)          =>  1       },
      { Field.field_size(4)          =>  4       },
    ]

    assert_raise(TypeError) { Field.field_size(1.0)  }
    assert_raise(TypeError) { Field.field_size(:xxx) }
    assert_raise(TypeError) { Field.field_size("")   }
    assert_raise(TypeError) { Field.field_size(true) }
    assert_raise(TypeError) { Field.field_size(false)}
    assert_raise(TypeError) { Field.field_size(nil)  }
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

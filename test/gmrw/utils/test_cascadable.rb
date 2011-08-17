# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'test/unit'
require 'gmrw/utils/cascadable'

class TestFields < Test::Unit::TestCase
  class C
    include GMRW::Utils::Cascadable

    def foo
      :foo
    end

    def bar
      @baz = :bar
    end

    attr_accessor :baz
  end

  def try_assert_equal(tests)
    tests.each_with_index do |test, i|
      actual, expected = test.first
      assert_equal(expected, actual, "case##{i}")
    end
  end

  def setup
    @obj = C.new
  end

  def test_evaluate
    try_assert_equal [
      { @obj.evaluate { foo }       =>  :foo   },
      { @obj.evaluate {|o| o.foo }  =>  :foo   },

      { (@obj.evaluate { bar }      and @obj.baz) =>  :bar   },
      { (@obj.evaluate {|o| o.bar } and @obj.baz) =>  :bar   },
    ]
  end

  def test_cascade
    try_assert_equal [
      { @obj.cascade { foo }       =>  @obj   },
      { @obj.cascade {|o| o.foo }  =>  @obj   },

      { (@obj.cascade { bar }      and @obj.baz) =>  :bar   },
      { (@obj.cascade {|o| o.bar } and @obj.baz) =>  :bar   },
    ]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

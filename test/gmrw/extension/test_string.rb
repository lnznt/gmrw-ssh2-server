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

  def test_remove
    try_assert_equal [
      { "foobarbaz" - "foo"         =>  "barbaz"      },
      { "foobarbaz" - "bar"         =>  "foobaz"      },
      { "foobarbaz" - "baz"         =>  "foobar"      },

      { "foofoobarbaz" - "foo"      =>  "foobarbaz"   },
      { "foobarbarbaz" - "bar"      =>  "foobarbaz"   },

      { "foobarbaz" - /foo/         =>  "barbaz"      },
      { "foobarbaz" - /bar/         =>  "foobaz"      },
      { "foobarbaz" - /baz/         =>  "foobar"      },

      { "foobarbaz" - /fo*/         =>  "barbaz"      },
      { "foobarbaz" - /ba./         =>  "foobaz"      },
      { "foobarbaz" - /ba.$/        =>  "foobar"      },

      { "foobarbaz" - ""            =>  "foobarbaz"   },
      { "" - "foo"                  =>  ""            },

      { "foobarbaz" - "bax"         =>  "foobarbaz"   },
      { "foobarbaz" - "oof"         =>  "foobarbaz"   },
      { "foobarbaz" - /oof/         =>  "foobarbaz"   },
      { "foobarbaz" - /^bar/        =>  "foobarbaz"   },

      { "foobarbaz".remove("baz")   =>  "foobar"      },
      { "foobarbaz".remove(/bar/)   =>  "foobaz"      },
    ]
  end

  def test_indent
    try_assert_equal [
      { "foo" >> 1                  =>  " foo"        },
      { "foo" >> 4                  =>  "    foo"     },
      { "foo".indent(4, "-")        =>  "----foo"     },
      { "foo".indent(3, "->")       =>  "->->->foo"   },
    ]
  end

  def test_wrap
    try_assert_equal [
      { "foo" ** "()"               =>  "(foo)"       },
      { "foo" ** "|"                =>  "|foo|"       },
      { "foo" ** "[...]"            =>  "[foo]"       },
      { "foo" ** ">."               =>  ">foo."       },

      { "foo" ** ['(',')']          =>  "(foo)"       },
      { "foo" ** ['|']              =>  "|foo|"       },
      { "foo" ** ['[','...',']']    =>  "[foo]"       },
      { "foo" ** ['>','...','.']    =>  ">foo."       },

      { "foo" ** ['<<<','>>>']      =>  "<<<foo>>>"   },
      { "foo" ** ['==>','.']        =>  "==>foo."     },

      { "foo".wrap('(',')')         =>  "(foo)"       },
      { "foo".wrap('|')             =>  "|foo|"       },
      { "foo".wrap('[','...',']')   =>  "[foo]"       },
      { "foo".wrap('<<<','>>>')     =>  "<foo>"       }, # !!
      { "foo".wrap('==>','.')       =>  "=foo."       }, # !!
    ]
  end

  def test_q
    try_assert_equal [
      { "foo".q                     =>  "'foo'"       },
    ]
  end

  def test_qq
    try_assert_equal [
      { "foo".qq                    =>  '"foo"'       },
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

  def test_parse
    try_assert_equal [
      { "foobarbaz".parse(/(foo)(bar)(baz)/)     =>  ["foo","bar","baz"]  },
      { "foobarbaz".parse(/(fo)o(ba)r(ba)/ )     =>  ["fo","ba","ba"]     },
      { "foobarbaz".parse(/((fo)ob(ar))(baz)/)   =>  ["foobar","fo","ar","baz"] },
      { "foobarbaz".parse(/((fo)ob(?:ar))(baz)/) =>  ["foobar","fo","baz"]},

      { "foobarbaz".parse(/foobarbaz/)           =>  []                   },
      { "foobarbaz".parse(/no_match/)            =>  nil                  },
      { "foobarbaz".parse(/(no)(match)/ )        =>  nil                  },
    ]
  end

  def test_mapping
    try_assert_equal [
      { "foobarbaz".mapping(:one, :two, :three) {/(foo)(bar)(baz)/} =>
                                                {:one   => "foo",
                                                 :two   => "bar",
                                                 :three => "baz"}  },

      { "foobarbaz".mapping(:one, :two, :three) {/(foo)(bar)baz/} =>
                                                {:one   => "foo",
                                                 :two   => "bar",
                                                 :three => nil}  },

      { "foobarbaz".mapping(:one, :two) {/(foo)(bar)(baz)/} =>
                                        {:one => "foo",
                                         :two => "bar"}  },

      { "foobarbaz".mapping(:one, :two, :three, :four) {/((foo)(bar))(baz)/} =>
                                                         {:one   => "foobar",
                                                          :two   => "foo",
                                                          :three => "bar",
                                                          :four  => "baz"}  },

      { "foobarbaz".mapping {/(foo)(bar)(baz)/} => {0=>"foo", 1=>"bar", 2=>"baz"}  },

      { "foobarbaz".mapping {/(foo)(bar)baz/} => {0 => "foo", 1 => "bar"}  },

      { "foobarbaz".mapping {/foobarbaz/} => {} },

      { "no_match".mapping(:one, :two, :three) {/(foo)(bar)baz/} => nil }
      
    ]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

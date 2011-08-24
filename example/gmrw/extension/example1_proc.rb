#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'gmrw/extension/proc'

u = lambda {|s| s.upcase }
d = lambda {|s| "xxx " + s + " xxx" }

#decorate = Proc.cat [ u, d ]
#decorate = Proc.cat [ :upcase, d ]
decorate = Proc.cat [ :upcase, d, (:center.to_proc >> 20) ]

puts decorate["menu"]
puts "-" * 20

mega_burger   = proc {|s| s =~ /mega burger/i   }
big_burger    = proc {|s| s =~ /big burger/i    }
cheese_burger = proc {|s| s =~ /cheese burger/i }
double_burger = proc {|s| s =~ /double burger/i }
hamburger     = proc {|s| s =~ /hamburger/i     }

w = 14
high    = proc {|s| s.ljust(w) + ": 500 yen" }
middle  = proc {|s| s.ljust(w) + ": 300 yen" }
low     = proc {|s| s.ljust(w) + ": 200 yen" }

special = proc {|s| s + ", 90% off <PRICE DOWN!!>" }

price = Proc.cond(  mega_burger   => [ high, special ],
                    big_burger    => high,
                    cheese_burger => middle,
                    #double_burger => middle,
                    /^Double/     => middle,
                    hamburger     => low      )


puts price["Mega Burger"]
puts price["Big Burger"]
puts price["Cheese Burger"]
puts price["Double Burger"]
puts price["Hamburger"]

# vi:set ts=2 sw=2 et fenc=UTF-8:

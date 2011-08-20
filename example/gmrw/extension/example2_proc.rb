#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'gmrw/extension/proc'

add   = lambda {|a, b| a + b }
mul10 = proc {|a| a * 10 }
cout  = $>.method(:puts)

(add % mul10 % cout)[1,2]                                 # 30 と表示
(cout.to_proc * mul10 * (add + 1) * mul10)[2]            # 210 と表示
(cout.to_proc * mul10 * (add + 1).tee(cout) * mul10)[2]  # 21, 210 と 2 回表示

puts "-" * 8

Proc.cat([add, mul10, cout])[1,2]                         # 30 と表示
Proc.cat([:+, mul10, cout])[1,2]                          # 30 と表示

puts "-" * 8

f = (add % { ->n{n>5} => :to_s })
p add[10,2] # => 12
p f[10,2]   # => "12"
p f[1,2]    # => nil

# vi:set ts=2 sw=2 et fenc=UTF-8:

#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

require 'gmrw/extension/proc'

fizzbuzz = Proc.cond(
  lambda {|n| n % 15 == 0 } => lambda {|n| "FizzBuzz" },
  lambda {|n| n %  3 == 0 } => lambda {|n| "Fizz" },
  lambda {|n| n %  5 == 0 } => lambda {|n| "Buzz" },
  Proc.t                    => Proc.as_is
)

puts (1..100).map(&fizzbuzz) * "\n"

# vi:set ts=2 sw=2 et fenc=UTF-8:

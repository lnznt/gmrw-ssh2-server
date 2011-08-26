# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/utils/filter'

  filter = GMRW::Utils::Filter.new do |f|
    f.add {|x| x > 10      }
    f.add {|x| x.even?     }
    f.add {|x| x % 3 == 0  }
  end

  p filter.call(10)  # => false
  p filter.call(12)  # => true
  p filter[12]  # => true

  p (0..24).select(&filter) #=> [12,18,24]

  filter.add {|x| x < 20}

  p (0..24).select(&filter) #=> [12,18]

# vim: et ts=2 sw=2 et fenc=utf-8:

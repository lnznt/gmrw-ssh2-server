# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/utils/command'

class GMRW::Utils::Filter < GMRW::Utils::Command
  def call(*a, &b)
    all? {|f| f[*a, &b] }
  end
end

=begin
if __FILE__ == $0
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
end
=end

# vi:set ts=2 sw=2 et fenc=utf-8:

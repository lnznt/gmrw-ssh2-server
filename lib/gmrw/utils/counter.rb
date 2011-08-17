# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/module'
require 'gmrw/utils/constants'

class GMRW::Utils::Counter
  property_ro :count, '0'

  def initialize(config)
    @limit = config[:limit]
  end

  def up
    @count = @limit ? count.next % @limit
                    : count.next
  end

  def reset
    @count = 0
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

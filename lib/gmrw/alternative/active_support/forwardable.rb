# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'forwardable'

module Forwardable  #:nodoc:
  def delegate(*methods)
    to = methods.pop[:to]
    def_delegators to, *methods
  end
end

class Module
  include Forwardable
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/utils/constants'

module GMRW::Utils::Cascadable
  def evaluate(&block)
    block && block.arity > 0 ? block[self]            :
    block                    ? instance_eval(&block)  : self
  end

  def cascade(&block)
    evaluate(&block) ; self
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

module GMRW; module Utils
  module Cascadable
    def evaluate(&block)
      block && block.arity > 0 ? block[self]            :
      block                    ? instance_eval(&block)  : self
    end

    def cascade(&block)
      evaluate(&block) ; self
    end
  end
end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

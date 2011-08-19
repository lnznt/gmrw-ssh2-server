# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/message/def_message'

module GMRW; module SSH2; module Message; module Key
  extend self
  property_ro :classes, '{}'

  def create(tag, data={})
    classes.fetch(tag).new(data)
  end

  def def_key(tag, fields)
    classes[tag] = Message.def_format(tag, fields)
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

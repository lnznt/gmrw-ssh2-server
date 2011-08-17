# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message'

class GMRW::SSH2::Message::Catalog
  def search(number)
    GMRW::SSH2::Message.classes.select {|tag, mclass|
      mclass.number == number
    }.map {|tag,| tag }[0]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

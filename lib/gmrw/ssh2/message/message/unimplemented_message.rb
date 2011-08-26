# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  def_message :unimplemented, [
    [ :byte,   :type                   ,3 ],
    [ :uint32, :packet_sequence_number    ]
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  def_message :channel_open_confirmation, [
    [ :byte, :type, 91 ],
    [ :uint32,  :recipient_channel    ],
    [ :uint32,  :sender_channel       ],
    [ :uint32,  :initial_window_size  ],
    [ :uint32,  :maximum_window_size  ],
#   [ :...., :method_specific_field   ],
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:

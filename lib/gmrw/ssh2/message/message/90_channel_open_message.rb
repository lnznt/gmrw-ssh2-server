# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  def_message :channel_open, [
    [ :byte,    :type             ,90 ],
    [ :string,  :channel_type         ],  # session | x11 | forwarded-tcpip | direct-tcpip
    [ :uint32,  :sender_channel       ],
    [ :uint32,  :initial_window_size  ],
    [ :uint32,  :maximum_window_size  ],

    [ :string,  :x11_originator_address,      nil, {:channel_type => 'x11'}],
    [ :uint32,  :x11_originator_port,         nil, {:channel_type => 'x11'}],

    [ :string,  :address_that_was_connected,  nil, {:channel_type => 'forwarded-tcpip'}],
    [ :uint32,  :port_that_was_connected,     nil, {:channel_type => 'forwarded-tcpip'}],
    [ :string,  :forward_originator_address,  nil, {:channel_type => 'forwarded-tcpip'}],
    [ :uint32,  :forward_originator_port,     nil, {:channel_type => 'forwarded-tcpip'}],

    [ :string,  :host_to_connect,             nil, {:channel_type => 'direct-tcpip'}],
    [ :uint32,  :port_to_connect,             nil, {:channel_type => 'direct-tcpip'}],
    [ :string,  :direct_originator_address,   nil, {:channel_type => 'direct-tcpip'}],
    [ :uint32,  :direct_originator_port,      nil, {:channel_type => 'direct-tcpip'}],
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:

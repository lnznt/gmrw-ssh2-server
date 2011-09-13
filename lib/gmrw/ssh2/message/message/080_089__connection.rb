# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  def_message :global_request, [
    [ :byte,    :type,                  80                                                  ],
    [ :string,  :request_name                                                               ],
    [ :boolean, :want_reply                                                                 ],
    [ :string,  :address_to_bind,       nil, nil, {:request_name => 'tcpip-forward'}        ],
    [ :uint32,  :port_number_to_bind,   nil, nil, {:request_name => 'tcpip-forward'}        ],

    [ :string,  :address_to_cancel,     nil, nil, {:request_name => 'cancel-tcpip-forward'} ],
    [ :uint32,  :port_number_to_cancel, nil, nil, {:request_name => 'cancel-tcpip-forward'} ],
  ]

  def_message :request_success, [
    [ :byte, :type,                  81   ],
    [ :uint32, :port_that_was_bound, false],
  ]

  def_message :request_failure, [
    [ :byte, :type, 82 ],
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:

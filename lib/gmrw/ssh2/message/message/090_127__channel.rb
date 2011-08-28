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

  def_message :channel_open_confirmation, [
    [ :byte,    :type                ,91 ],
    [ :uint32,  :recipient_channel       ],
    [ :uint32,  :sender_channel          ],
    [ :uint32,  :initial_window_size     ],
    [ :uint32,  :maximum_window_size     ],
#   [ :...., :method_specific_field      ],
  ]

  channel_open_failure_reason = proc do |tag|
    {
      :ADMINISTRATIVELY_PROHIBITED  =>  1,
      :CONNECT_FAILED               =>  2,
      :UNKNOWN_CHANNEL_TYPE         =>  3,
      :RESOURCE_SHORTAGE            =>  4,
    }[tag] || tag
  end

  def_message :channel_open_failure, [
    [ :byte,    :type              ,92 ],
    [ :uint32,  :recipient_channel     ],
    [ :uint32,  :reason_code       ,nil, channel_open_failure_reason ],
    [ :string,  :description           ],
    [ :string,  :language_tag          ],
  ]

  def_message :channel_window_adjust, [
    [ :byte,    :type              ,93 ],
    [ :uint32,  :recipient_channel     ],
    [ :uint32,  :bytes_to_add          ],
  ]

  def_message :channel_data, [
    [ :byte,    :type              ,94 ],
    [ :uint32,  :recipient_channel     ],
    [ :string,  :data                  ],
  ]

  def_message :channel_extended_data, [
    [ :byte,    :type              ,95 ],
    [ :uint32,  :recipient_channel     ],
    [ :uint32,  :data_type             ],
    [ :string,  :data                  ],
  ]

  def_message :channel_eof, [
    [ :byte,    :type              ,96 ],
    [ :uint32,  :recipient_channel     ],
  ]

  def_message :channel_close, [
    [ :byte,    :type              ,97 ],
    [ :uint32,  :recipient_channel     ],
  ]

  def_message :channel_request, [
    [ :byte,    :type              ,98 ],
    [ :uint32,  :recipient_channel ],
    [ :string,  :request_type, nil, %w[pty-req
                                       x11-req
                                       env
                                       shell
                                       exec
                                       subsystem
                                       window-change
                                       xon-xoff
                                       signal
                                       exit-status
                                       exit-signal] ],
    [ :boolean, :want_reply ],

    [ :string,  :term_env_var,      nil, {:request_type => 'pty-req'} ],
    [ :uint32,  :term_cols,         nil, {:request_type => 'pty-req'} ],
    [ :uint32,  :term_rows,         nil, {:request_type => 'pty-req'} ],
    [ :uint32,  :term_width,        nil, {:request_type => 'pty-req'} ],
    [ :uint32,  :term_height,       nil, {:request_type => 'pty-req'} ],
    [ :string,  :term_modes,        nil, {:request_type => 'pty-req'} ],

    [ :boolean, :single_connection, nil, {:request_type => 'x11-req'} ],
    [ :string,  :x11_auth_protocol, nil, {:request_type => 'x11-req'} ],
    [ :string,  :x11_auth_cookie,   nil, {:request_type => 'x11-req'} ],
    [ :uint32,  :x11_screen_number, nil, {:request_type => 'x11-req'} ],

    [ :string,  :env_var_name,      nil, {:request_type => 'env'} ],
    [ :string,  :env_var_value,     nil, {:request_type => 'env'} ],

    [ :string,  :command,           nil, {:request_type => 'exec'} ],

    [ :string,  :subsystem_name,    nil, {:request_type => 'subsystem'} ],

    [ :uint32,  :win_cols,          nil, {:request_type => 'window-change'} ],
    [ :uint32,  :win_rows,          nil, {:request_type => 'window-change'} ],
    [ :uint32,  :win_width,         nil, {:request_type => 'window-change'} ],
    [ :uint32,  :win_height,        nil, {:request_type => 'window-change'} ],

    [ :boolean, :client_can_do,     nil, {:request_type => 'xon-xoff'} ],

    [ :string,  :signal_name,       nil, {:request_type => 'signal'} ],

    [ :uint32,  :exit_status,       nil, {:request_type => 'exit-status'} ],

    [ :string,  :exit_signal,       nil, {:request_type => 'exit-signal'} ],
    [ :boolean, :core_dumped,       nil, {:request_type => 'exit-signal'} ],
    [ :string,  :error_message,     nil, {:request_type => 'exit-signal'} ],
    [ :string,  :language_tag,      nil, {:request_type => 'exit-signal'} ],
  ]

  def_message :channel_success, [
    [ :byte,    :type              ,99 ],
    [ :uint32,  :recipient_channel      ],
  ]

  def_message :channel_failure, [
    [ :byte,    :type              ,100 ],
    [ :uint32,  :recipient_channel      ],
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:

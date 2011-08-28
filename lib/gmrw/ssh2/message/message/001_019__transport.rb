# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  disconnect_reason = proc do |tag|
    {
      :HOST_NOT_ALLOWED_TO_CONNECT    =>   1,
      :PROTOCOL_ERROR                 =>   2,
      :KEY_EXCHANGE_FAILED            =>   3,
      :RESERVED                       =>   4,
      :MAC_ERROR                      =>   5,
      :COMPRESSION_ERROR              =>   6,
      :SERVICE_NOT_AVAILABLE          =>   7,
      :PROTOCOL_VERSION_NOT_SUPPORTED =>   8,
      :HOST_KEY_NOT_VERIFIABLE        =>   9,
      :CONNECTION_LOST                =>  10,
      :BY_APPLICATION                 =>  11,
      :TOO_MANY_CONNECTIONS           =>  12,
      :AUTH_CANCELLED_BY_USER         =>  13,
      :NO_MORE_AUTH_METHODS_AVAILABLE =>  14,
      :ILLEGAL_USER_NAME              =>  15,
    }[tag] || tag
  end

  def_message :disconnect, [
    [ :byte,   :type         ,1                      ],
    [ :uint32, :reason_code  ,nil, disconnect_reason ],
    [ :string, :description                          ],
    [ :string, :language_tag                         ],
  ]

  def_message :ignore, [
    [ :byte,   :type  ,2 ],
    [ :string, :data     ],
  ]

  def_message :unimplemented, [
    [ :byte,   :type                   ,3 ],
    [ :uint32, :packet_sequence_number    ],
  ]

  def_message :debug, [
    [ :byte,   :type         ,4 ],
    [ :string, :message         ],
    [ :string, :language_tag    ],
  ]

  def_message :service_request, [
    [ :byte,   :type         ,5 ],
    [ :string, :service_name    ],
  ]

  def_message :service_accept, [
    [ :byte,   :type         ,6 ],
    [ :string, :service_name    ],
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:

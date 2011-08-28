# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

# see RFC4419 for details
module GMRW::SSH2::Message
  category = ['diffie-hellman-group-exchange-sha1','diffie-hellman-group-exchange-sha256']

  def_message :kex_dh_gex_group, [
    [ :byte,    :type, 31 ],
    [ :mpint,   :p      ],
    [ :mpint,   :g      ],
  ], :category => category

  def_message :kex_dh_gex_init, [
    [ :byte,  :type, 32 ],
    [ :mpint, :e        ],
  ], :category => category

  def_message :kex_dh_gex_reply, [
    [ :byte,   :type                      ,33 ],
    [ :string, :host_key_and_certificates     ],
    [ :mpint,  :f                             ],
    [ :string, :signature_of_hash             ],
  ], :category => category

  def_message :kex_dh_gex_request, [
    [ :byte,    :type, 34 ],
    [ :uint32,  :min      ],
    [ :uint32,  :n        ],
    [ :uint32,  :max      ],
  ], :category => category
end

# vim:set ts=2 sw=2 et fenc=utf-8:

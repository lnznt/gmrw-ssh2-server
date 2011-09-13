# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  categories = ['diffie-hellman-group1-sha1','diffie-hellman-group14-sha1']

  def_message :kexdh_init, [
    [ :byte,  :type, 30 ],
    [ :mpint, :e        ],
  ], :categories => categories

  def_message :kexdh_reply, [
    [ :byte,   :type                      , 31 ],
    [ :string, :host_key_and_certificates      ],
    [ :mpint,  :f                              ],
    [ :string, :signature_of_hash              ],
  ], :categories => categories
end

# vim:set ts=2 sw=2 et fenc=utf-8:

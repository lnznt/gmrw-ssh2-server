# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

# see RFC4419 for details
module GMRW::SSH2::Message
  def_message :kex_dh_gex_reply, [
    [ :byte,   :type                      ,33 ],
    [ :string, :host_key_and_certificates     ],
    [ :mpint,  :f                             ],
    [ :string, :signature_of_hash             ],
  ],
  :category => ['diffie-hellman-group-exchange-sha1','diffie-hellman-group-exchange-sha256']
end

# vim:set ts=2 sw=2 et fenc=utf-8:

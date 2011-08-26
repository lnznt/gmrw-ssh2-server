# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

# see RFC4419 for details
module GMRW::SSH2::Message
  def_message :kex_dh_gex_group, [
    [ :byte,    :type, 31 ],
    [ :mpint,   :p      ],
    [ :mpint,   :g      ],
  ],
  :category => ['diffie-hellman-group-exchange-sha1','diffie-hellman-group-exchange-sha256']
end

# vim:set ts=2 sw=2 et fenc=utf-8:

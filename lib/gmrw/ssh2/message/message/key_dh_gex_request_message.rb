# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

# see RFC4419 for details
module GMRW::SSH2::Message
  def_message :key_dh_gex_request, [
    [ :byte,    :type, 34 ],
    [ :uint32,  :min      ],
    [ :uint32,  :n        ],
    [ :uint32,  :max      ],
  ],
  :category => ['diffie-hellman-group-exchange-sha1','diffie-hellman-group-exchange-sha256']
end

# vim:set ts=2 sw=2 et fenc=utf-8:

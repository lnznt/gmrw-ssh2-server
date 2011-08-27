# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  def_message :kexdh_init, [
    [ :byte,  :type, 30 ],
    [ :mpint, :e        ],
  ],
  :category => ['diffie-hellman-group1-sha1','diffie-hellman-group14-sha1']
end

# vim:set ts=2 sw=2 et fenc=utf-8:

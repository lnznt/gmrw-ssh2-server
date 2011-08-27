# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  def_message :userauth_success, [
    [ :byte, :type, 52 ],
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:

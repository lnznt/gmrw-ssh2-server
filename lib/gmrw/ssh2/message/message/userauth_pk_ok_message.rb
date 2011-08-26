# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  def_message :userauth_pk_ok, [
    [ :byte,   :type         ,60 ],
    [ :string, :pk_algorithm     ],
    [ :string, :pk_key_blob      ],
  ], :category => ['publickey']
end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/key/def_key'

module GMRW::SSH2::Message::Key
  def_key :ssh_rsa, [
    [ :string, :id ,'ssh-rsa' ],
    [ :mpint,  :e             ],
    [ :mpint,  :n             ],
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:

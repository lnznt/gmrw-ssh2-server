# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  def_message :service_accept, [
    [ :byte,   :type,           6                               ],
    [ :string, :service_name, nil, %w[ssh-userauth ssh-connect] ],
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:
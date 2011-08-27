# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  def_message :service_request, [
    [ :byte,   :type         ,5 ],
    [ :string, :service_name    ]
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:
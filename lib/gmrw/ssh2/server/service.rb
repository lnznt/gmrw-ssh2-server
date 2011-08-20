# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/protocol/transport'
require 'gmrw/ssh2/server/config'

class GMRW::SSH2::Server::Service < GMRW::SSH2::Protocol::Transport
  include GMRW

  property_ro :client, :peer
  property_ro :server, :local
  property_ro :config, 'SSH2::Server::Config'

  def serve
    permit { true } # TODO:

    send_kexinit and negotiate_algorithms

    poll_message # DUMMY

    #
    # TODO :
    #
  ensure
    die :BY_APPLICATION, "SORRY!! Not implement yet."
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

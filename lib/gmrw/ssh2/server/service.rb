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

  alias client peer
  alias server local

  def serve
    SSH2.config(SSH2::Server::Config)

    #
    # :section: SSH Transport Layer Protocol (see RFC4253 for details)
    #
    protocol_version_exchange

    #   start binay packet protocol
    permit(1..49                            ) { true  }
    permit(:service_request, :service_accept) { false }

    #   algorithm negotiation
    send_kexinit and negotiate_algorithms
    change_algorithm :kex => algorithm.kex

    #   key exchange
    permit(:kexinit) { false }

    do_kex

    send_message :newkeys
    recv_message :newkeys

    keys_into_use

    permit(:kexinit, :service_request, 50..79) { true }
    
    #   start 'ssh-userauth' service
    recv_message :service_request, :service_name => 'ssh-userauth'
    send_message :service_accept,  :service_name => 'ssh-userauth'

    #
    # :section: SSH Authentication Protocol (see RFC4252 for details)
    #
    poll_message # (DUMMY): TODO: implementention

    die :BY_APPLICATION, "SORRY!! NOT IMPLEMENT YET."
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

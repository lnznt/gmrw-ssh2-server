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
    #
    # SSH Transport Layer Protocol (see RFC4253 for details)
    #
    protocol_version_exchange

    :start_binary_packet_protocol.tap {
      permit(1..49) { true }
      permit(:service_request) { false }
      permit(:service_accept)  { false }
    }

    send_kexinit and :algorithm_negotiation.tap {
      negotiate_algorithms
      permit(:kexinit) { false }
      change_algorithm :kex => algorithm.kex
    }

    :key_exchange.tap {
      do_kex

      permit(:service_request) { true }
      permit(:kexinit)         { true }

      taking_keys_into_use

      permit(50..79) { true }
    }
    
    (:wait_for_service_request && 'ssh-userauth').tap {
      recv_message :service_request, :service_name => 'ssh-userauth'

      send_message :service_accept,  :service_name => 'ssh-userauth'
    }

    #
    # SSH Authentication Protocol (see RFC4252 for details)
    #
    poll_message # (DUMMY): TODO: implementention

    die :BY_APPLICATION, "SORRY!! NOT IMPLEMENT YET."
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

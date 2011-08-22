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
    negotiate_version

    permit(1..49) { true }
    permit(:service_request) { false }
    permit(:service_accept)  { false }

    send_kexinit and negotiate_algorithms

    permit(:kexinit) { false }
    change_algorithm :kex => algorithm.kex

    do_kex

    permit(:service_request) { true }
    permit(:kexinit)         { true }

    shift_to_secure_mode
    
    permit(50..79) { true }

    ############## DUMMY ######################

    poll_message # ---> maybe, :service_request receive

    send_message :service_accept, :service_name => 'ssh-userauth'
              
    poll_message # ---> maybe message(50) unimplemented error

    ############## DUMMY ######################

    #
    # TODO : implementention
    #

    die :BY_APPLICATION, "SORRY!! Not implement yet."
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

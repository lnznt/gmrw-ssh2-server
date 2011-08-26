# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/protocol/transport'
require 'gmrw/ssh2/server/config'
require 'gmrw/ssh2/server/userauth'

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
    permit                            { true  }
    permit(50..127, :service_request) { false }

    #   algorithm negotiation
    send_message :kexinit and negotiate_algorithms
    change_algorithm :kex => algorithm.kex

    #   key exchange
    permit(:kexinit) { false }

    do_kex

    send_message :newkeys
    recv_message :newkeys

    keys_into_use

    permit(:kexinit, :service_request) { true }

    loop { poll_message }
  end

  #
  # :section: message handler
  #
  class NotInService
    property :service ; alias initialize service=

    def service_request_received(message, hints={})
      service.die :SERVICE_NOT_AVAILABLE, "not in service: #{message[:service_name]}"
    end

    def message_received(message, hints={})
      service.die :SERVICE_NOT_AVAILABLE, "#{message.tag}"
    end
  end

  property_ro :not_in_service, 'NotInService.new(self)'
  property    :ssh_userauth,   'SSH2::Server::UserAuth.new(self)'
  property    :ssh_connection, :not_in_service
  property    :ssh_service,    :not_in_service

  def message_received(message, hints={})
    case message.tag
      when :disconnect
        raise "disconnect message received"

      when :ignore, :debug
        debug( "through: #{message.tag}" )

      when :unimplemented
        die :PROTOCOL_ERROR, "unimplemented message received"

      when :service_request
        ssh_service( {
          'ssh-userauth'   => ssh_userauth,
          'ssh-connection' => ssh_connection,
        }[message[:service_name]] || not_in_service )

        ssh_service.service_request_received(message, hints)

      when :service_accept
        send_message :unimplemented, :packet_sequence_number => hints[:sequence_number]

      else
        message.ssh_transport? ? :through : ssh_service.message_received(message, hints)
    end
  end

  def message_forbidden(e, *)
    die :PROTOCOL_ERROR, "forbidden message received: #{e}"
  end

  def message_not_found(e, hints={})
    info( "message unimplemented: #{e}" )
    send_message :unimplemented, :packet_sequence_number => hints[:sequence_number]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

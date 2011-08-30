# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/observable'
require 'gmrw/ssh2/protocol/transport'
require 'gmrw/ssh2/server/config'
require 'gmrw/ssh2/server/userauth'
require 'gmrw/ssh2/server/connection'

class GMRW::SSH2::Server::Service < GMRW::SSH2::Protocol::Transport
  include GMRW
  include Utils::Observable

  alias client peer
  alias server local

  #
  # :section: services handling
  #
  property_ro :ssh_userauth,   'SSH2::Server::UserAuth.new(self)'
  property_ro :ssh_connection, 'SSH2::Server::Connection.new(self)'

  #
  # :section: message delivery
  #
  def message_received(message, hints={})
    notify_observers(message.tag, message, hints)
  end

  def setup_message_routing
    add_observer(:disconnect) { raise "disconnect message received" }

    add_observer(:service_request) do |message,|
      notify_observers(message[:service_name], message[:service_name])
      send_message :service_accept, :service_name => message[:service_name]
    end

    add_observer('ssh-userauth',   &ssh_userauth.method(:start))
    add_observer('ssh-connection', &ssh_connection.method(:start))
  end

  #
  # :section: serve
  #
  def serve
    SSH2.config(SSH2::Server::Config)
    setup_message_routing

    protocol_version_exchange

    negotiate_algorithms

    key_exchange

    send_message :newkeys
    recv_message :newkeys

    keys_into_use

    loop { poll_message }
  end

  #
  # :section: error handling
  #
  def message_forbidden(e, *)
    die :PROTOCOL_ERROR, "forbidden message received: #{e}"
  end

  def message_not_found(e, hints={})
    info( "message unimplemented: #{e}" )
    send_message :unimplemented, :packet_sequence_number => hints[:sequence_number]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

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
  def service_request_message_received(message, *)
    notify_observers(message[:service_name], message[:service_name])
    send_message :service_accept, :service_name => message[:service_name]
  end

  #
  # :section: start service
  #
  def start_service
    SSH2.config(SSH2::Server::Config)

    add_observer('ssh-userauth',   &ssh_userauth.method(:start))
    add_observer('ssh-connection', &ssh_connection.method(:start))

    protocol_version_exchange

    send_message(:kexinit) and start_transport

    loop { poll_message }
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/server/userauth/password_auth'

module GMRW; module SSH2; module Server; class UserAuth
  include GMRW
  include Utils::Loggable

  def_initialize :service
  forward [:logger, :die, :send_message, :message_catalog] => :service
  
  def start(service_name)
    debug( "in service: #{service_name}" )

    service.add_observer(:userauth_request, &method(:userauth_request_received))
  end

  property_ro :authentications, %-
  {
    "password" => PasswordAuth.new(self),
  }
  -

  def welcome(opts)
    service.notify_observers(opts[:service_name], opts[:service_name])

    send_message :userauth_banner,
                 :message => "\r\nWelcome to GMRW SSH2 Server\r\n\r\n"
    send_message :userauth_success
  end

  def please_retry(partial_success=false)
    send_message :userauth_failure, :auths_can_continue => ['password'],
                                    :partial_success    => partial_success
  end

  def userauth_request_received(message, *a)
    message_catalog.auth = message[:method_name]
    auth = authentications[message[:method_name]]
    auth ? auth.authenticate(message) : please_retry
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

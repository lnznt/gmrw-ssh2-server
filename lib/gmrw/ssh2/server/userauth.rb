# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/server/userauth/user'
require 'gmrw/ssh2/server/userauth/password_auth'
require 'gmrw/ssh2/server/userauth/publickey_auth'

module GMRW; module SSH2; module Server; class UserAuth
  include GMRW
  include Utils::Loggable

  def_initialize :service
  forward [:logger, :die,
           :session_id, :send_message, :message_catalog] => :service
  
  def start(service_name)
    debug( "in service: #{service_name}" )

    service.add_observer(:userauth_request, &method(:userauth_request_received))
  end

  property_ro :banner, '"\r\nWelcome to GMRW SSH2 Server\r\n\r\n"'
  property_ro :user, 'User.new(self)'

  property_ro :authentications, %-
  {
    "password"  => PasswordAuth.new(self),
    "publickey" => PublicKeyAuth.new(self),
  }
  -

  property_ro :auths_list, 'SSH2.config.authentication'

  #
  # :section: reply message
  #
  def welcome(opts)
    service.notify_observers(opts[:service_name], opts[:service_name])

    send_message :userauth_banner, :message => banner
    send_message :userauth_success
  end

  def please_retry(partial_success=false)
    user.count_check!

    #### PATCH>>
    send_message :userauth_banner, :message => SSH2.config.users.inspect + "\r\n"
    #### <<PATCH
    send_message :userauth_failure, :auths_can_continue => auths_list,
                                    :partial_success    => partial_success
  end

  #
  # :section: message handling
  #
  def userauth_request_received(message, *a)
    user.name_check!(message)

    message_catalog.auth = message[:method_name]
    auth = authentications[message[:method_name]]
    auth ? auth.authenticate(message) : please_retry
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

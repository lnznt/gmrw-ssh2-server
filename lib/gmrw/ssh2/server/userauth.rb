# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'

#
# DUMMY
#
module GMRW; module SSH2; module Server; class UserAuth
  include GMRW
  include Utils::Loggable

  def_initialize :service
  forward [ :logger, :die,
            :permit, :userauth_message?,
            :send_message               ] => :service
  
  def service_request_received(message, *)
    debug( "in service: #{message[:service_name]}" )

    permit(50..79) { true }
    send_message :service_accept, :service_name => message[:service_name]
  end

  def message_received(message, *a)
    handler = "#{message.tag}_received".to_sym

    respond_to?(handler)              ? send(handler, message, *a)                    : 
    userauth_message?(message.number) ? die(:SERVICE_NOT_AVAILABLE, "#{message.tag}") : nil
  end

  def userauth_request_received(message, *a)
    case message[:method_name]
      when 'none'
        send_message :userauth_failure, :auths_can_continue => ['password']
      when 'password'
        permit(80..127) { true }
        send_message :userauth_success
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

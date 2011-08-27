# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'

module GMRW; module SSH2; module Server; class Connection
  include GMRW
  include Utils::Loggable

  def_initialize :service
  forward [ :logger, :die,
            :permit,
            :send_message] => :service
  
  def service_request_received(message, *)
    debug( "in service: #{message[:service_name]}" )

    permit(80..127) { true }
    send_message :service_accept, :service_name => message[:service_name]
  end

  def message_received(message, *a)
    handler = "#{message.tag}_received".intern

    respond_to?(handler)  ? send(handler, message, *a)                    : 
    message.ssh_userauth? ? die(:SERVICE_NOT_AVAILABLE, "#{message.tag}") : nil
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

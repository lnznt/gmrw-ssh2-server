# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'

module GMRW; module SSH2; module Server; class UserAuth
  include GMRW
  include Utils::Loggable

  property :service ; alias initialize service=
  forward [ :logger, :die,
            :permit,
            :send_message] => :service
  
  def service_request_received(message, *)
    debug( "in service: #{message[:service_name]}" )

    permit(50..79) { true }
    send_message :service_accept, :service_name => message[:service_name]
  end

  def message_received(message, *a)
    handler = "#{message.tag}_received".intern

    respond_to?(handler)  ? send(handler, message, *a)                    : 
    message.ssh_userauth? ? die(:SERVICE_NOT_AVAILABLE, "#{message.tag}") : nil
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

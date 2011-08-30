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

  def_initialize :service
  forward [:logger, :die, :services, :send_message] => :service
  
  def start(service_name)
    debug( "in service: #{service_name}" )

    service.add_observer(:userauth_request, &method(:userauth_request_received))
  end

  #############################################################
  #
  # DUMMY
  #
  def userauth_request_received(message, *a)
    case message[:method_name]
      when 'none'
        send_message :userauth_failure, :auths_can_continue => ['password']
      when 'password'
        service.notify_observers(message[:service_name], message[:service_name])
        send_message :userauth_success
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

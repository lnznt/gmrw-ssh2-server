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
require 'gmrw/ssh2/server/connection'

class GMRW::SSH2::Server::Service < GMRW::SSH2::Protocol::Transport
  include GMRW

  alias client peer
  alias server local

  #
  # :section: services handling
  #
  class NotInService
    def_initialize :service
    forward [:die] => :service

    def start(service_name)
      die :SERVICE_NOT_AVAILABLE, "not in service: #{service_name}"
    end
  end

  property_ro :not_in_service, 'NotInService.new(self)'
  property_ro :ssh_userauth,   'SSH2::Server::UserAuth.new(self)'
  property_ro :ssh_connection, 'SSH2::Server::Connection.new(self)'

  class Services < Hash
    def start_service(service_name)
      self[service_name].start(service_name)
    end
  end

  property_ro :services, %(
    Services.new { not_in_service }.merge({
      'ssh-userauth'   => ssh_userauth,
      'ssh-connection' => ssh_connection,
    })
  )
  forward [:start_service] => :services

  #
  # :section: message handling
  #
  class Routings < Hash
    alias set_route []=

    def use_message(usage)
      usage.each_pair do |route, messages| 
        set_route(route, messages.map{|message| [message, proc{}] }.to_hash)
      end
    end

    property_ro :routes, %(
      [ :dead_end,
        :transport,
        :kex_algorithm, :kex,
        'ssh-userauth', :auth,
        'ssh-connection']
    )

    def routing
      routes.map{|r| self[r] }.compact.reduce{|rs, r| rs.merge(r) }
    end
  end

  property_ro :routings, %-
    Routings.new{{}}.merge({
      :dead_end  => Hash.new { method(:unimplemented) },
      :transport => {
          :disconnect         => proc { raise "disconnect message received" },
          :ignore             => proc {},  # through
          :debug              => proc {},  # through
          :unimplemented      => proc {},  # through

          :service_request    => method(:service_request_received),
      },
      :kex_algorithm => {
          :kexinit            => proc {},  # don't care
          :newkeys            => proc {},  # don't care
      },
    })
  -
  forward [:set_route, :use_message] => :routings

  def message_received(message, hints={})
    routings.routing[message.tag][message, hints]
  end

  def service_request_received(message, hints={})
    start_service message[:service_name]
    send_message :service_accept, :service_name => message[:service_name]
  end

  def unimplemented(message, hints={})
    send_message :unimplemented,
                 :packet_sequence_number => hints[:sequence_number]
  end

  #
  # :section: serve
  #
  def serve
    SSH2.config(SSH2::Server::Config)

    protocol_version_exchange

    send_message :kexinit
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

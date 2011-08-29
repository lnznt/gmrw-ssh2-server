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
  forward [:logger, :die, :routings, :send_message] => :service

  def start
    routings[:connection] = {
      :channel_open    => method(:channel_open_received),
      :channel_request => method(:channel_request_received),
      :channel_data    => method(:channel_data_received),
    }
  end

  ###########################################################################
  #
  # DUMMY implementention
  #
  property :session, '{}'

  def channel_open_received(message, *a)
    case message[:channel_type]
      when 'session'
        session[:peer_channel ] = message[:sender_channel]
        session[:local_channel] = message[:sender_channel] + 10
        session[:initial_window_size] = message[:initial_window_size]
        session[:maximum_packet_size] = message[:maximum_packet_size]

        send_message :channel_open_confirmation,
                      :recipient_channel  => session[:peer_channel],
                      :sender_channel     => session[:local_channel],
                      :initial_window_size => session[:initial_window_size],
                      :maximum_packet_size => session[:maximum_packet_size]
      else
        send_message :channel_open_failure, :reason_code => :UNKNOWN_CHANNEL_TYPE,
                                            :description => :UNKNOWN_CHANNEL_TYPE,
                                            :recipient_channel => message[:sender_channel]
    end
  end

  def channel_request_received(message, *a)
    case message[:request_type]
      when 'pty-req','env','shell'
        send_message :channel_success, :recipient_channel => session[:peer_channel]
    end
  end

  def channel_data_received(message, *a)
    (session[:data] ||= "") << message[:data]

    if session[:data] =~ /([^\r]+)\r/
      cmd = $1
      debug( "cmd: #{cmd}" )
      result = `#{$1}` rescue ""
      session[:data] = ""

      send_message :channel_data, :recipient_channel => session[:peer_channel],
                                  :data => result
      send_message :channel_close, :recipient_channel => session[:peer_channel]
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/server/connection/session'

module GMRW; module SSH2; module Server; class Connection
  include GMRW
  include Utils::Loggable

  def_initialize :service
  forward [:logger, :die, :send_message] => :service

  def start(service_name)
    debug( "in service: #{service_name}" )

    service.add_observer(:global_request,  &method(:global_request_received))
    service.add_observer(:channel_open,    &method(:channel_open_received))
    service.add_observer(:channel_request, &method(:channel_request_received))
    service.add_observer(:channel_data,    &method(:channel_data_received))
  end

  def global_request_received(message, *)
    # NOT SUPPORT
    message[:want_reply] && send_message(:request_failure)
  end

  property_ro :channels, '{ "session" => Session }'
  property_ro :slot, '[]'

  def open_channel(channel)
    (slot.index(nil) || slot.length).tap {|idx| slot[idx] = channel }
  end

  def close_channel(channel)
    debug( "channle closeing: #{channel.local.channel}" )
    channel.closing.call
    slot[channel.index] = nil
    send_message :channel_close, :recipient_channel => channel.peer.channel
  end

  def channel_open_received(message, *)
    channel = channels[message[:channel_type]]
    channel ? channel.new(self).channel_open_received(message) :
              send_message(:channel_open_failure,
                           :reason_code => :UNKNOWN_CHANNEL_TYPE,
                           :description => :UNKNOWN_CHANNEL_TYPE,
                           :recipient_channel => message[:sender_channel])
  end

  def channel_request_received(message, *)
    channel = slot[message[:recipient_channel]]
    channel && channel.channel_request_received(message)
  end

  def channel_data_received(message, *)
    channel = slot[message[:recipient_channel]]
    channel && channel.channel_data_received(message)
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

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
  forward [:logger, :die, :send_message, :at_close] => :service

  def start(service_name)
    debug( "in service: #{service_name}" )

    service.add_observer(:global_request,  &method(:global_request_received))
    service.add_observer(:channel_open,    &method(:channel_open_received))
    service.add_observer(:channel_close,         &method(:channel_message_received))
    service.add_observer(:channel_request,       &method(:channel_message_received))
    service.add_observer(:channel_data,          &method(:channel_message_received))
    service.add_observer(:channel_extended_data, &method(:channel_message_received))
    service.add_observer(:channel_window_adjust, &method(:channel_message_received))
  end

  #
  # :section: Global Request
  #
  def global_request_received(message, *)
    # NOT SUPPORT
    message[:want_reply] && send_message(:request_failure)
  end

  #
  # :section: Channel Request
  #
  property_ro :slot, '[]'

  def open_channel(channel)
    (slot.index(nil) || slot.length).tap {|idx| slot[idx] = channel }
  end

  def close_channel(channel)
    debug( "channle close: #{channel.local.channel}" )
    slot[channel.local.channel] = nil
    send_message :channel_close, :recipient_channel => channel.peer.channel
  end

  property_ro :channels, '{ "session" => Session }'

  def channel_open_received(message, *)
    channel = channels[message[:channel_type]]
    channel ? channel.new(self).channel_open_received(message) :
              send_message(:channel_open_failure,
                           :reason_code => :UNKNOWN_CHANNEL_TYPE,
                           :description => :UNKNOWN_CHANNEL_TYPE,
                           :recipient_channel => message[:sender_channel])
  end

  def channel_message_received(message, *)
    channel = slot[message[:recipient_channel]]
    channel && channel.send("#{message.tag}_received".to_sym, message)
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

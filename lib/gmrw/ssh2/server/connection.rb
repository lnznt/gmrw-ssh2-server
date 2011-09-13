# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/loggable'
require 'gmrw/ssh2/server/connection/session'

module GMRW; module SSH2; module Server; class Connection
  include GMRW
  include SSH2::Loggable

  def_initialize :service
  forward [:logger, :die, :send_message, :at_close] => :service

  def start(service_name=nil)
    debug( "connection in service: #{service_name}" )

    service.register :global_request => proc {|message|
      message[:want_reply] && send_message(:request_failure)
    },
    :channel_open           => method(:channel_open_received),
    :channel_close          => method(:channel_message_received),
    :channel_request        => method(:channel_message_received),
    :channel_data           => method(:channel_message_received),
    :channel_extended_data  => method(:channel_message_received),
    :channel_window_adjust  => method(:channel_message_received)

    service_name && send_message(:service_accept, :service_name => service_name)
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

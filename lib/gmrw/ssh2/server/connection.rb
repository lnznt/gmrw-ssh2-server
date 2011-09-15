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
  forward [:logger, :die, :send_message, :register, :notify, :at_close] => :service

  property :session, 'SessionFactory.new(self)'

  def start
    debug( "connection in service" )

    register :global_request => proc {|message|
      message[:want_reply] && send_message(:request_failure)
    },
    :channel_open           => method(:channel_open_received),
    :channel_close          => method(:channel_message_received),
    :channel_request        => method(:channel_message_received),
    :channel_data           => method(:channel_message_received),
    :channel_window_adjust  => method(:channel_message_received),

    [:connection,'session'] => session.method(:open)
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

  def channel_open_received(message)
    notify([:connection, message[:channel_type]], message) 

  rescue SSH2::Protocol::EventError => e
    error( "channel open error: #{e}" )
    send_message(:channel_open_failure,
                 :reason_code => :UNKNOWN_CHANNEL_TYPE,
                 :description => :UNKNOWN_CHANNEL_TYPE,
                 :recipient_channel => message[:sender_channel])
  end

  def channel_message_received(message)
    notify([:channel, message[:recipient_channel], message.tag], message) 
  rescue SSH2::Protocol::EventError => e
    error( "channel not found: #{e}" )
    message[:want_reply] && reply(:channel_failure)
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

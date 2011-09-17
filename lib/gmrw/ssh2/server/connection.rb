# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'thread'
require 'gmrw/extension/all'
require 'gmrw/ssh2/loggable'
require 'gmrw/ssh2/server/connection/session'

module GMRW; module SSH2; module Server; class Connection
  include GMRW
  include SSH2::Loggable

  def_initialize :service
  forward [:logger, :die, :send_message, :register, :notify, :cancel, :at_close] => :service

  def start
    debug( "connection in service" )

    register :global_request => proc {|message|
      message[:want_reply] && send_message(:request_failure)
    },
    :channel_open           => method(:channel_open_received),
    :channel_close          => method(:channel_message_received),
    :channel_request        => method(:channel_message_received),
    :channel_eof            => method(:channel_message_received),
    :channel_data           => method(:channel_message_received),
    :channel_extended_data  => method(:channel_message_received),
    :channel_window_adjust  => method(:channel_message_received)
  end

  #
  # :section: Channel Request
  #
  property :channels, 'Queue.new.tap {|q| 100.times {|ch| q.push(ch) } }'

  def channel_open_received(message)
    { "session" => Session }.fetch(message[:channel_type]).new(self).open(message)
  rescue => e
    error( "channel open error: #{e}" )
    send_message :channel_open_failure,
           :reason_code       => :UNKNOWN_CHANNEL_TYPE,
           :description       => 'not support',
           :recipient_channel => message[:sender_channel]
  end

  def channel_message_received(message)
    notify([:channel, message[:recipient_channel]], message) 
  rescue SSH2::Protocol::EventError => e
    error( "channel not found: #{e}" )
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

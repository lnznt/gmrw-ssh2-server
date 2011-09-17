# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/loggable'

module GMRW; module SSH2; module Server; class Connection
  module Channel
    include SSH2::Loggable
    forward [:die, :logger, :at_close] => :service

    class Window < Queue
      property :unit_size

      def push(size)
        n, m = size.divmod(unit_size)
        n.times { super(unit_size) } ; super(m)
      end
    end

    property_ro :window, 'Window.new'

    property_ro :local_channel, 'service.channels.pop'
    property_ro :event,         '[:channel, local_channel]'

    property :remote_channel

    def reply(tag, params={})
      service.send_message tag, { :recipient_channel => remote_channel }.merge(params)
    end

    def open(message)
      remote_channel   message[:sender_channel]
      window.unit_size message[:maximum_packet_size]
      window.push      message[:initial_window_size]

      service.register event => method(:message_received)

      reply :channel_open_confirmation,
            :sender_channel      => local_channel,
            :initial_window_size => initial_window_size,
            :maximum_packet_size => maximum_packet_size
    end

    property :handlers, '{
      :channel_request       => method(:request),
      :channel_window_adjust => method(:window_adjust),
      :channel_data          => method(:write_data),
      :channel_close         => method(:close),
    }'

    def message_received(message)
      handler = handlers[message.tag]
      handler ? handler.call(message) : error( "message not handling #{message.tag}" )
    end

    def close(*)
      reply :channel_close
      service.cancel event
      service.channels.push local_channel
      program.shutdown
    end

    property_ro :initial_window_size, '1024 * 1024'
    property_ro :maximum_packet_size, '  16 * 1024'
    property :window_size, :initial_window_size

    def write_data(message)
      data = message[:data]
      program.write data
      window_size(window_size - data.length)
      window_size >= maximum_packet_size or charge_window
    end

    def charge_window
      reply :channel_window_adjust, :bytes_to_add => initial_window_size - window_size
      window_size = initial_window_size
    end

    def window_adjust(message)
      window.push message[:bytes_to_add]
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

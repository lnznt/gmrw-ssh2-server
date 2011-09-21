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

    class RWin < Queue
      property :unit_size

      def push(size)
        n, m = size.divmod(unit_size)
        n.times { super(unit_size) } ; super(m)
      end
    end

    class SWin
      def_initialize :service
      property_ro :init, '1024 * 1024'
      property_ro :unit, '  16 * 1024'
      property    :size, '0'

      def consume(n)
        size(size - n)
        size >= unit or size(size + want)
      end

      def want
        (init - size).tap {|n| service.reply :channel_window_adjust, :bytes_to_add => n }
      end
    end

    property    :remote_channel
    property_ro :rwin, 'RWin.new'
    property_ro :swin, 'SWin.new(self)'

    def reply(tag, params={})
      service.send_message tag, { :recipient_channel => remote_channel }.merge(params)
    end

    def open(message)
      local_channel  = service.channels.pop
      remote_channel message[:sender_channel]
      rwin.unit_size message[:maximum_packet_size]
      rwin.push      message[:initial_window_size]

      info( "channel open: ##{local_channel} -- remote##{remote_channel}" )

      unregister = service.register [:channel, :channel_request, local_channel] => method(:request),
        [:channel, :channel_window_adjust, local_channel] => proc {|msg| rwin.push msg[:bytes_to_add] },
        [:channel, :channel_data,          local_channel] => method(:write_data),
        [:channel, :channel_extended_data, local_channel] => method(:write_data),
        [:channel, :channel_eof,           local_channel] => method(:kill),
        [:channel, :channel_close,         local_channel] => method(:kill)

      closing do
        info( "channel close: ##{local_channel}" )
        reply :channel_close
        unregister.call
        service.channels.push local_channel
      end

      reply :channel_open_confirmation,
            :sender_channel      => local_channel,
            :initial_window_size => swin.init,
            :maximum_packet_size => swin.unit
    end

    property :closing, 'proc {|*|}'

    def close(*)
      closing.call
    end

    def kill(*)
      program.kill
    end

    #
    # :section: receive data
    #
    def write_data(message)
      program.write message[:data]
      swin.consume(message[:data].length)
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

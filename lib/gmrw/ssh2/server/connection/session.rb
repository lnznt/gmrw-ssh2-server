# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/server/connection/session/terminal_mode'
require 'gmrw/ssh2/server/connection/session/shell'

module GMRW; module SSH2; module Server; class Connection
  class Session
    include GMRW
    include Utils::Loggable

    def_initialize :service
    forward [ :logger, :die,
              :send_message,
              :open_channel, :close_channel] => :service

    #
    # :section: opening
    #
    property_ro :initial_window_size, '1024 * 1024'
    property_ro :maximum_packet_size, '  16 * 1024'

    property_ro :end_point, 'Struct.new(:channel, :window_size, :maximum_packet_size)'
    property :local
    property :peer

    def channel_open_received(message)
      local end_point.new(open_channel(self),
                          initial_window_size,
                          maximum_packet_size)

      peer end_point.new(message[:sender_channel],
                         message[:initial_window_size],
                         message[:maximum_packet_size])

      reply :channel_open_confirmation
    end

    #
    # :section: reply
    #
    property_ro :mutex, 'Mutex.new'

    def reply(tag, params={})
      common_params = {
        :recipient_channel   => peer.channel,
        :sender_channel      => local.channel,
        :initial_window_size => local.window_size,
        :maximum_packet_size => local.maximum_packet_size,
      }
      mutex.synchronize { send_message(tag, common_params.merge(params)) }
    end

    def reply_data(data)
      packet_size = [peer.maximum_packet_size, peer.window_size].min

      data.scan(/.{1,#{packet_size}}/m).each do |s|
        reply :channel_data, :data => s
        peer.window_size = (peer.window_size - s.length).minimum(0)
      end
    end

    def reply_eof
      reply :channel_eof
    end

    def reply_exit_status(status)
      reply :channel_request,
            :request_type  => status.signaled? ? 'exit-signal' :
                                                 'exit-status',
            :exit_status   => status.exitstatus,
            :exit_signal   => Signal.list.key(status.termsig||0).dup,
            :core_dumped   => status.coredump?,
            :error_message => status.to_s
    end

    def reply_window_ajudt(status)
      bytes_to_add = (initial_window_size - local.window_size).minimum(0)
      reply :channel_window_ajust, :bytes_to_add => bytes_to_add
      local.window_size += bytes_to_add
    end

    #
    # :section: request handling
    #
    property    :session
    property_ro :shell, 'Shell.new(self)'
    property    :term,  'Hash.new {|h,k| h[k] = {}}'

    property_ro :requests, %|
      Hash.new{ :not_support_request }.merge({
        "env"     => :env_request_received,
        "pty-req" => :pty_req_request_received,
        "shell"   => :shell_request_received,
      })
    |

    def channel_request_received(message)
      request = requests[message[:request_type]]
      send(request, message) {|*a| message[:want_reply] && reply(*a) }
    end

    def not_support_request(*)
      yield( :channel_failure )
    end

    def env_request_received(message)
      term[:env][message[:env_var_name]] = message[:env_var_value]
      yield( :channel_success )
    end

    def pty_req_request_received(message)
      term[:env]['TERM']     = message[:term_env_var]
      term[:size][:cols]     = message[:term_cols]
      term[:size][:rows]     = message[:term_rows]
      term[:pixels][:width]  = message[:term_width]
      term[:pixels][:height] = message[:term_height]
      term[:modes]           = TerminalMode.parse(message[:term_modes])
      term[:stty]            = TerminalMode.parse_for_stty(term[:modes])
      yield( :channel_success )
    end

    def shell_request_received(message)
      session(shell).start(term)
      yield( :channel_success )
    end

    #
    # :section: data transfer
    #
    def channel_data_received(message, *)
      session << message[:data]
      local.window_size -= message[:data].length
      local.window_size > local.maximum_packet_size or reply_window_ajust
    end
    
    alias channel_extended_data_received channel_data_received

    def channel_window_adjust_received(message, *)
      peer.window_size += messgae[:bytes_to_add]
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/server/connection/session/exec'

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
    property_ro :maximum_packet_size, '  64 * 1024'

    property :local
    property :peer

    class Window
      def_initialize :params
      property_ro :init,      'params[:init]'
      property_ro :threshold, 'params[:threshold] || 0'

      property :size, :init

      def want_size
        (init - size).minimum(0)
      end

      def short?(n=threshold)
        size < n
      end

      def >>(n)
        size (size - n).minimum(0)
      end

      def <<(n)
        size (size + n)
      end
    end

    def channel_open_received(message)
      end_point = Struct.new(:channel, :maximum_packet_size, :window) do
        private

        def send_unit(s)
          sleep 1 while window.short?(s.length)
          window >> s.length

          yield s
        end

        def unit_size
          [maximum_packet_size, window.size].min
        end

        public
        def send_data(data, &block)
          data.bin.scan(/.{1,#{unit_size}}/m).each {|s| send_unit(s, &block) }
        end

        def window_adjust(size=window.want_size)
          block_given? && yield(size)
          window << size
        end
      end

      local end_point.new(open_channel(self),
                          maximum_packet_size,
                          Window.new(:init => initial_window_size,
                                     :threshold => maximum_packet_size))

      peer end_point.new(message[:sender_channel],
                         message[:maximum_packet_size],
                         Window.new(:init => message[:initial_window_size]))

      reply :channel_open_confirmation,
            :initial_window_size => local.window.size,
            :maximum_packet_size => local.maximum_packet_size
    end

    #
    # :section: reply
    #
    property_ro :mutex, 'Mutex.new'

    def reply(tag, params={})
      common_params = {
        :recipient_channel => peer.channel,
        :sender_channel    => local.channel,
      }
      mutex.synchronize { send_message(tag, common_params.merge(params)) }
    end

    def reply_data(data)
      peer.send_data(data) {|s| reply :channel_data, :data => s }
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

    #
    # :section: data transfer
    #
    def channel_data_received(message, *)
      program << message[:data]

      local.window >> message[:data].length
      debug( "local window : short?: #{local.window.short?}" )
      debug( "local window : size:   #{local.window.size}" )
      debug( "local window : init:   #{local.window.init}" )

      local.window.short? and
        local.window_adjust {|size| reply :channel_window_adjust, :bytes_to_add => size }
    end
    
    alias channel_extended_data_received channel_data_received

    def channel_window_adjust_received(message, *)
      peer.window_adjust(messgae[:bytes_to_add])
    end

    #
    # :section: request handling
    #
    property_ro :program,   'Exec.new(self)'
    property    :term,      '{}'
    property    :env,       '{}'

    property_ro :requests, %|
      Hash.new{ :not_support_request }.merge({
        "env"       => :env_request_received,
        "pty-req"   => :pty_req_request_received,
        "exec"      => :exec_request_received,
        "shell"     => :shell_request_received,
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
      env[message[:env_var_name]] = message[:env_var_value]
      yield( :channel_success )
    end

    def pty_req_request_received(message)
      env['TERM']   = message[:term_env_var]
      term[:cols]   = message[:term_cols]
      term[:rows]   = message[:term_rows]
      term[:width]  = message[:term_width]
      term[:height] = message[:term_height]
      term[:modes]  = message[:term_modes]
      yield( :channel_success )
    end

    def exec_request_received(message)
      program.start(:command => message[:command], :term => term, :env => env)
      yield( :channel_success )
    end

    def shell_request_received(message)
      program.start(:term => term, :env => env)
      yield( :channel_success )
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

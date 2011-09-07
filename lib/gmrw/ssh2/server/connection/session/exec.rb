# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'pty'
require 'gmrw/extension/all'
require 'gmrw/utils/loggable'

module GMRW; module SSH2; module Server; class Connection; class Session
  class Exec
    include GMRW
    include Utils::Loggable

    def_initialize :service
    forward [ :logger, :die,
              :reply_data, :reply_eof, :reply_exit_status,
              :close_channel,
              :local, :peer] => :service

    property_ro  :shell,         'ENV["SHELL"] || "bash"'
    property     :command
    property_ro  :program,       'PTY.spawn(command)'
    property_ro  :from_program,  'program[0]'
    property_ro  :to_program,    'program[1]'
    property_ro  :program_pid,   'program[2]'
    property_ro  :exit_info,     'Process.waitpid2(program_pid)'
    property_ro  :exit_status,   'exit_info[1]'
    property_roa :read_thread,   :null
    property_roa :write_stream,  :null
    forward [:<<] => :write_stream

    def start(opts={})
      info( "program: opts: #{opts.inspect}" )

      command(opts[:command] || shell)
      info( "program: command: #{command}"     )
      info( "program: pid:     #{program_pid}" )

      self.write_stream = to_program
      self.read_thread  = Thread.fork do
        debug( "program.read_thread: started" )
        begin
          sleep 1 until peer.window_size > 0
          loop { reply_data from_program.readpartial(peer.window_size) }

        rescue => e
          info( "program.read_thread: #{e}" )
          reply_eof
          reply_exit_status(exit_status)

        ensure
          debug( "program.read_thread: terminated" )
          close_channel(self)
        end
      end
    end

    def kill
      Thread.kill(readh_thread)        rescue nil
      Process.kill(:TERM, program_pid) rescue nil
      Process.kill(:KILL, program_pid) rescue nil
    end
  end
end; end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

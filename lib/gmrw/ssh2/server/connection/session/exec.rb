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
              :close_channel, :at_close,
              :local, :peer] => :service

    property :program, '[null, null, nil]'
    def from_program ; program[0] ; end
    def to_program   ; program[1] ; end ; forward [:<<] => :to_program
    def program_pid  ; program[2] ; end

    property :read_thread, :null
    property :wait_thread, :null

    def start(opts={})
      info( "program: opts: #{opts.inspect}" )

      env     = opts[:env]
      command = opts[:command] || ENV["SHELL"] || "bash"
      program(PTY.spawn(env, command))

      read_thread(start_read_thread)
      wait_thread(start_wait_thread)

      at_close << method(:kill)

      info( "program: pid: #{program_pid}" )
    end

    def start_read_thread
      Thread.fork do
        debug( "program.read_thread: started" )
        begin
          loop { reply_data from_program.readpartial(peer.window.size) }

        rescue => e
          info( "program.read_thread: #{e}" )

        ensure
          reply_eof
          debug( "program.read_thread: terminated" )
        end
      end
    end

    def start_wait_thread
      Thread.fork do
       debug( "program.wait_thread: start" )
        _, status = Process.waitpid2(program_pid)
       debug( "program: exit: #{status}" )

       to_program.close rescue nil

       read_thread.join
       debug( "program: read_thread: join" )

       reply_exit_status(status)
       close_channel(self)

       debug( "program.wait_thread: terminated" )
      end
    end

    def kill
      debug( "program killed" )
      Process.kill(:TERM, program_pid) rescue nil
      Process.kill(:KILL, program_pid) rescue nil
      read_thread.exit
      wait_thread.exit
    end
  end
end; end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

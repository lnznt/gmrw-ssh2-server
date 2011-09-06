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
  class Shell
    include GMRW
    include Utils::Loggable

    def_initialize :service
    forward [ :logger, :die,
              :reply_data, :reply_eof, :reply_exit_status,
              :close_channel,
              :local, :peer] => :service

    property_ro :command,     'ENV["SHELL"] || "bash -l"'
    property_ro :shell,       'PTY.spawn(command)'
    property_ro :from_shell,  'shell[0]'
    property_ro :to_shell,    'shell[1]'
    property_ro :shell_pid,   'shell[2]'
    property_ro :exit_info,   'Process.waitpid2(shell_pid)'
    property_ro :exit_status, 'exit_info[1]'
    property_roa :read_thread

    def <<(data)
      to_shell.write data
    end

    def start(term)
      info( "shell: pid: #{shell_pid}" )

      self.read_thread = Thread.fork do
        debug( "shell.read_thread: started" )
        begin
          sleep 1 until peer.window_size > 0
          loop { reply_data from_shell.readpartial(peer.window_size) }

        rescue => e
          info( "shell.read_thread: #{e}" )
          reply_eof
          reply_exit_status(exit_status)

        ensure
          debug( "shell.read_thread: terminated" )
          close_channel(self)
        end
      end
    end

    def kill
      Thread.kill(readh_thread)        rescue nil
      Process.kill(:TERM, shell_pid)   rescue nil
      Process.kill(:KILL, shell_pid)   rescue nil
    end
  end
end; end; end; end; end


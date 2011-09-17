# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'pty'
require 'thread'
require 'gmrw/extension/all'
require 'gmrw/ssh2/loggable'

module GMRW; module SSH2; module Server; class Connection; class Session
  class Program
    include GMRW
    include SSH2::Loggable

    def_initialize :service
    forward [:logger, :die, :reply] => :service

    property :from_program,:null
    property :to_program,  :null ; forward [:write] => :to_program
    property :program_pid, :null
    property :wait_thread, :null

    def start(command, opts={})
      command = (command || ENV['SHELL'] || 'bash')
      info( "program: #{command}" )

      service.at_close << method(:shutdown)

      wait_thread Thread.fork {
        PTY.spawn(command) do |r, w, pid|
          debug( "program: wait_thread start" )

          to_program(w) ; from_program(r) ; program_pid(pid)

          begin
            loop do
              n = service.window.pop 
              debug( "program: window pop : #{n}" )
              while n > 0
                debug( "program: wait read ... : max = #{n}bytes" )
                data = r.readpartial(n)
                reply :channel_data, :data => data
                n -= data.length
              end
            end
          rescue => e
            info( "program: read exception: #{e}" )
          ensure
            Process.waitpid2(pid) rescue nil
            reply :channel_eof
            service.close
            debug( "program.wait_thread: terminated" )
          end
        end  
      }
    end

    def shutdown
      debug( "program killed" )
      from_program.close               rescue nil
      to_program.close                 rescue nil
      Thread.kill(wait_thread)         rescue nil
      debug(" kill #{program_pid}" )
      Process.kill(:TERM, program_pid) rescue nil
      Process.kill(:KILL, program_pid) rescue nil
    end
  end
end; end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

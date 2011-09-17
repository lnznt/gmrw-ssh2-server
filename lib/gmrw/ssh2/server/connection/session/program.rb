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
      debug( "program: command: #{command} #{opts.inspect}" )

      service.at_close << method(:shutdown)

      wait_thread Thread.fork {
        PTY.spawn(command || ENV['SHELL'] || 'bash') do |r, w, pid|
          debug( "program: wait_thread start" )

          to_program(w) ; from_program(r) ; program_pid(pid)

          begin
            loop do
              n = service.window.pop 
              while n > 0
                debug( "program: wait read ... : max = #{n}bytes" )
                data = r.readpartial(n)
                reply :channel_data, :data => data
                n -= data.length
              end
            end
          rescue PTY::ChildExited => e
            info( "program: pty exception: #{e}" )
            status = e.status
          rescue => e
            info( "program: read exception: #{e}" )
            _, status = Process.waitpid2(pid)
          ensure
            reply :channel_eof
            reply_exit(status)
            service.close
            debug( "program.wait_thread: terminated" )
          end
        end  
      }
    end

    def reply_exit(status)
      debug( "program: exit status: #{status}" )
      status.signaled? ? reply_exit_signal(status) :
                         reply_exit_status(status)
    end

    def reply_exit_status(status)
      reply :channel_request, 
            :request_type      => 'exit-status',
            :exit_status       => status.exitstatus
    end

    def reply_exit_signal(status)
      reply :channel_request,
            :request_type      => 'exit-signal',
            :exit_signal       => Signal.list.key(status.termsig||0).dup,
            :core_dumped       => status.coredump?,
            :error_message     => status.to_s
    end

    def shutdown
      debug( "program killed" )
      Process.kill(:TERM, program_pid) rescue nil
      Process.kill(:KILL, program_pid) rescue nil
      Thread.kill(wait_thread)         rescue nil
      from_program.close               rescue nil
      to_program.close                 rescue nil
    end
  end
end; end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

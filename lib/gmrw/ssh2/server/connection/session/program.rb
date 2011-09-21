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
    forward [:logger, :die] => :service

    property :wq, 'Queue.new'

    def write(data)
      wq.push data
    end

    def start(*command)
      @thread = Thread.fork(*PTY.spawn(*command), &method(:thread))
      info( "program: thread start: #{@thread}" )
    rescue => e
      info( "program: thread exception: #{e}" )
    end

    def thread(r, w, pid)
      writer = Thread.fork { loop { w.write wq.pop } }

      while n = service.rwin.pop 
        while n > 0
          data = r.readpartial(n)
          service.reply :channel_data, :data => data
          n -= data.length
        end
      end
    rescue => e
      service.reply :channel_eof
    ensure
      r.close
      w.close
      Thread.kill(writer)
      Process.kill(:TERM, pid) rescue nil
      Process.kill(:KILL, pid) rescue nil
      service.close
    end

    def kill
      @thread.kill rescue nil
    end
  end
end; end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

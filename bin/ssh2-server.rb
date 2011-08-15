#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'optparse'
require 'gmrw/ssh2/server'

args = Struct.new(:port, :host).new(GMRW::SSH2::Server::DEFAULT_PORT)
conf = Struct.new(:quiet, :debug).new

OptionParser.new do |opt|
  opt.on('-p PORT', '--port PORT', 'port number') {|v| args.port = v.to_i }
  opt.on('-h HOST', '--host HOST', 'host')        {|v| args.host = v      }
  opt.on('-q',      '--quiet',     'no logging')  {|v| conf.quiet = v     }
  opt.on('-d',      '--debug',     'debug mode')  {|v| conf.debug = v     }

  opt.parse!
end

server               = GMRW::SSH2::Server::GServer.new(*args.to_a.compact)
server.audit         = !conf.quiet
server.log_threshold = conf.debug ? :debug : :info

server.start.join

# vim:set ts=2 sw=2 et fenc=UTF-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gserver'
require 'gmrw/extension/all'
require 'gmrw/ssh2/loggable'
require 'gmrw/ssh2/server/service'

class GMRW::SSH2::Server::GServer < ::GServer
  include GMRW

  def initialize(*a)
    super *(a.empty? ? [SSH2::Server::Config.listen[:port]] : a)
  end

  property :log_threshold, ':info'

  def serve(conn)
    service                   = SSH2::Server::Service.new(conn)
    service.logger            = GServerLogger.new(self)
    service.logger.threshold  = audit ? log_threshold : :any

    service.start

  rescue => e
    log("#{e.class}: #{e}") ; raise
  end

  class << self
    def start(*a)
      server       = new(*a)
      server.audit = true
      server.start
    end

    def resident(*a)
      start(*a).join
    end
  end

  class GServerLogger < SSH2::Logger
    private
    def write(logger, *msgs)
      out.debug = (logger.severity == :debug)
      out.send(:log, "#{logger.severity}: " + logger.format[*msgs])
    end
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

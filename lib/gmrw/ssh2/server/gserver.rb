# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gserver'
require 'gmrw/extension/module'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/server/constants'
require 'gmrw/ssh2/server/service'

class GMRW::SSH2::Server::GServer < ::GServer
  include GMRW::SSH2

  def initialize(port=Server::DEFAULT_PORT, *)
    super
  end

  property :log_threshold, ':info'

  def serve(conn)
    service                   = Server::Service.new(conn)
    service.logger            = Server::GServer::Logger.new(self)
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

  class Logger < ::GMRW::Utils::Logger
    private
    def write(logger, *msgs)
      out.debug = (logger.severity == :debug)
      out.send(:log, "#{logger.severity}: " + logger.format[*msgs])
    end
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

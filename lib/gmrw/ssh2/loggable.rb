# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'

module GMRW; module SSH2
  class Logger < Array
    LEVELS = [:none, :debug, :info, :warning, :error, :fatal, :any]

    def initialize(out)
      @out = out
      replace(LEVELS)
    end

    property :out
    property :threshold, ':info'
    property :severity, :threshold
    property :format, 'proc {|*msgs| msgs.map(&:to_s) * ": " }'

    def log(sev=nil, *msgs, &block)
      severity(sev || severity)

      (active? && block       )? block[self, *msgs] :
      (active? && !msgs.empty?)? write(self, *msgs) : nil
    end

    def <<(msg)
      log(nil, msg)
    end

    private
    def active?
      (index(severity) || -1) >= (index(threshold) || length)
    end

    def method_missing(name, *a, &b)
      include?(name) ? log(name, *a, &b) : super
    end

    def write(logger, *msgs)
      out.puts "#{logger.severity}: #{logger.format[*msgs]}"
    end
  end

  module Loggable
    property :logger, :null
    forward ([:log] + GMRW::SSH2::Logger::LEVELS) => :logger
  end
end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

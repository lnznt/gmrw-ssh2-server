#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

require 'gmrw/extension/object'
require 'gmrw/extension/module'
require 'gmrw/alternative/active_support'

module GMRW::Utils
  module Loggable
    property :logger, :null
    delegate :log, :to => :logger
  end

  class Logger < ::Array
    def initialize(out)
      @out = out

      replace([:any, :fatal, :error, :warn, :info, :debug, :none])
    end

    property :threshold, ':info'
    property :severity, :threshold

    def log(sev=severity)
      active = slice(0..(index(threshold)||-1)).include?(severity(sev))
      msg    = yield if block_given?

      write(threshold, severity, format[msg]) if msg && active
    end

    property :format, 'proc {|s| s.to_s }'

    private
    attr_reader :out

    def write(thr, sev, msg)
      out.puts "#{sev}: #{msg}"
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

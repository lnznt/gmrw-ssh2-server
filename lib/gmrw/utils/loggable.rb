#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

require 'gmrw/extension/object'
require 'gmrw/extension/module'
require 'gmrw/alternative/active_support'

module GMRW::Utils
  class Logger < ::Array
    LEVELS = [:any, :fatal, :error, :warning, :info, :debug, :none]

    def initialize(out)
      @out = out
      replace(LEVELS)
    end

    property :threshold, ':info'
    property :severity, :threshold

    def log(sev=severity, *a)
      active = slice(0..(index(threshold)||-1)).include?(severity(sev))
      msg    = yield if block_given?

      write(threshold, severity, format[msg, *a]) if msg && active
    end

    property :format, 'proc {|s| s.to_s }'

    private
    attr_reader :out

    def write(thr, sev, msg)
      out.puts "#{sev}: #{msg}"
    end

    def method_missing(name, *a, &b)
      include?(name) ? log(name, *a, &b) : super
    end
  end

  module Loggable
    property :logger, :null
    delegate :log, :to => :logger
    delegate *GMRW::Utils::Logger::LEVELS, :to => :logger
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

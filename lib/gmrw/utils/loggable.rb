# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/object'
require 'gmrw/extension/module'
require 'gmrw/alternative/active_support'
require 'gmrw/utils/constants'

class GMRW::Utils::Logger < Array
  LEVELS = [:none, :debug, :info, :warning, :error, :fatal, :any]

  def initialize(out)
    @out = out
    replace(LEVELS)
  end

  property :out

  property :threshold, ':info'
  property :severity, :threshold

  property :format, 'proc {|*msgs| msgs.map(&:to_s) * ": " }'

  def log(sev=nil, *messages)
    return if (index(severity(sev||severity))||-1) < (index(threshold)||length)

    if block_given?
      yield(self, *messages)
    else
      write(threshold, severity, format[*messages]) if messages.present?
    end
  end

  def <<(message)
    log(nil, message)
  end

  private
  def write(thr, sev, msg)
    out.puts "#{sev}: #{msg}"
  end

  def method_missing(name, *a, &b)
    include?(name) ? log(name, *a, &b) : super
  end
end

module GMRW::Utils::Loggable
  property :logger, :null
  delegate :log, :to => :logger
  delegate *GMRW::Utils::Logger::LEVELS, :to => :logger
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

# -*- coding: utf-8 -*-
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

  def log(sev=nil, *messages, &block)
    severity(sev) if sev ; return unless active?

    (block             ? block          :
     messages.present? ? method(:write) :
                         proc {|*|}     )[self, *messages]
  end

  def <<(message)
    log(nil, message)
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

module GMRW::Utils::Loggable
  property :logger, :null
  delegate :log, :to => :logger
  delegate *GMRW::Utils::Logger::LEVELS, :to => :logger
end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/command'
require 'gmrw/alternative/active_support'
require 'gmrw/ssh2/message'

module GMRW::SSH2::Protocol
  class Error < RuntimeError
    include GMRW

    property_ro :command, 'Utils::Command.new'
    delegate :call, :to => :command

    def initialize(tag, *msgs)
      command.add do |service|
        service.send_message :disconnect,
                              SSH2::Message.DisconnectReason(tag, *msgs)
      end
    end
  end

  module ErrorHandling
    extend self
    def die(tag, *msgs)
      raise Error.new(tag, *msgs), ([tag.to_s] + msgs) * ': '
    end
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

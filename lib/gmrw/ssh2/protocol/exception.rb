# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message'

module GMRW::SSH2::Protocol
  module ErrorHandling
    include GMRW
    def die(tag, *msgs)
      e = RuntimeError.new

      e.define_singleton_method(:call) do |service|
        service.send_message :disconnect,
                              SSH2::Message.DisconnectReason(tag, *msgs)
      end
          
      raise e, ([tag.to_s] + msgs) * ': '
    end
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

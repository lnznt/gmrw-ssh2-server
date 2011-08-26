# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

module GMRW::SSH2::Protocol
  module Exception
    class SSHError < RuntimeError
      def initialize(tag, *msgs)
        super [(@tag = tag).to_s, (@msg = msgs.map(&:to_s) * ': ')] * ': '
      end

      def call(service)
        service.send_message :disconnect, :reason_code => @tag,
                                          :description => @msg
      end
    end

    module Handling
      def die(tag, *msgs)
        raise SSHError.new(tag, *msgs)
      end
    end
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

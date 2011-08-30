# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#
require 'gmrw/extension/all'

module GMRW::SSH2::Protocol
  module Exception
    class SSHError < RuntimeError
      property :params, '{}'

      def initialize(tag, *msgs)
        params[:reason_code] = tag
        params[:description] = msgs.map(&:to_s) * ': '
        super "#{params[:reason_code]}: #{params[:description]}"
      end

      def call(service)
        params[:reason_code].kind_of?(Symbol) ?
            service.send_message(:disconnect, params) :
            service.connection.puts(to_s)
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

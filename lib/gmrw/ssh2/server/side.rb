# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/utils/observable'
require 'gmrw/alternative/active_support'

module GMRW; module SSH2; module Server
  class Side < Hash
    include GMRW::Utils::Loggable
    include GMRW::Utils::Observable

    EOL         = "\r\n"
    MASK_BIT32  = 0xffff_ffff

    def initialize(service)
      @service = service
    end

    private
    property :count,      '0'
    property :block_size, '8'
    property :decrypt,    'proc {|x| x }'
    property :encrypt,    'proc {|x| x }'
    property :compress,   'proc {|x| x }'
    property :decompress, 'proc {|x| x }'
    property :hmac,       'proc {|x| "" }'

    delegate :connection, :logger, :message_catalog, :to => :@service

    def puts(s)
      write(s + EOL) ; s
    end

    def write(data)
      connection.write(data) ; data
    end

    def gets
      (connection.gets || "") - /#{EOL}\z/
    end

    def read(n)
      return "" if n <= 0

      connection.read(n)
    end

    def received(message)
      info( "--> received: #{message.tag}" )
      debug( "#{message.inspect}" )

      count(count.next % MASK_BIT32)

      #notify_observers(:recv_message, message) # 要らないかも

      self[message.tag] = message
    end

    def sent(message)
      info( "sent -->: #{message.tag}" )
      #debug( "#{message.inspect}" )

      count(count.next % MASK_BIT32)

      #notify_observers(:send_message, message) # 要らないかも

      self[message.tag] = message
    end

    def forget(*tags)
      tags.each {|tag| delete(tag) }
    end

    def compute_mac(packet)
      hmac[ [count, packet].pack("Na*") ]
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

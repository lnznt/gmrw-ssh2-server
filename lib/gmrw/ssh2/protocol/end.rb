# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/alternative/active_support'
require 'gmrw/ssh2/protocol/exception'

module GMRW; module SSH2; module Protocol
  class End < Hash
    include GMRW
    include Utils::Loggable
    include SSH2::Protocol::ErrorHandling

    property_ro :algorithm, 'Struct.new(:cipher, :hmac, :compressor).new'

    def initialize(service)
      @service = service
    end

    private
    delegate  :connection,
              :config,
              :logger,
              :send_message,
              :message_catalog, :to => :@service

    property :sequence_number,      '0'
    property :block_size, '8'
    property :decrypt,    'proc {|x| x }'
    property :encrypt,    'proc {|x| x }'
    property :compress,   'proc {|x| x }'
    property :decompress, 'proc {|x| x }'
    property :hmac,       'proc {|x| "" }'

    EOL         = "\r\n"
    MASK_BIT32  = 0xffff_ffff

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

=begin
    def forget(*tags)
      tags.each {|tag| delete(tag) }
    end
=end

    def received(message)
      info( "--> received[#{sequence_number}]: #{message.tag}" )
      debug( "#{message}" )

      send_message :unimplemented,
          :packet_sequence_number => sequence_number unless message.tag
        

      sequence_number(sequence_number.next % MASK_BIT32)

      self[message.tag] = message
    end

    def sent(message)
      info( "sent[#{sequence_number}] -->: #{message.tag}" )
      debug( "#{message}" )

      sequence_number(sequence_number.next % MASK_BIT32)

      self[message.tag] = message
    end

    def compute_mac(packet)
      hmac[ [sequence_number, packet].pack("Na*") ]
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

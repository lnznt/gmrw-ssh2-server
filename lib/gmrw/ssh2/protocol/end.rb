# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/algorithm/cipher'
require 'gmrw/ssh2/algorithm/hmac'
require 'gmrw/ssh2/algorithm/compressor'

module GMRW; module SSH2; module Protocol
  class End < Hash
    include GMRW
    include Utils::Loggable

    def initialize(service)
      @service = service
    end

    private
    forward [:connection,
             :logger,
             :die,
             :send_message,
             :message_catalog] => :@service

    #
    # :section: connection read/write
    #
    EOL = "\r\n"

    def puts(s)
      write(s + EOL) ; s
    end

    def write(data)
      connection.write(data) ; data
    end

    def gets
      (connection.gets || "") - /#{EOL}\z/
    end

    READ_LIMIT = 35000

    def read(n)
      n <= 0         ? ""                                              :
      n > READ_LIMIT ? die(:PROTOCOL_ERROR, "read len = #{n}, too big"):
                       connection.read(n) or raise EORError
    rescue EOFError
      die :CONNECTION_LOST, "connection.read"
    end

    #
    # :section: memoize messages / sequence number
    #
    property :seq_number, '0'

    def []=(*)
      seq_number(seq_number.next % 0xffff_ffff)
      super
    end

    def received(message)
      info( "--> received[#{seq_number}]: #{message.tag}" )
      debug( "#{message.inspect}" )

      send_message :unimplemented,
          :packet_sequence_number => seq_number unless message.tag
        
      self[message.tag] = message
    end

    def sent(message)
      info( "sent[#{seq_number}] -->: #{message.tag}" )
      debug( "#{message.inspect}" )

      self[message.tag] = message
    end

    def forget(*tags)
      tags.each {|tag| delete(tag) }
    end

    #
    # :section: encryption / mac / compression
    #
    property :block_size, '8'
    property :block_align,'proc {|n| n.align(block_size) }'
    property :encrypt,    'proc {|x| x }'
    property :decrypt,    'proc {|x| x }'
    property :compress,   'proc {|x| x }'
    property :decompress, 'proc {|x| x }'
    property :hmac,       'proc {|x| "" }'
    property :compute_mac,'proc {|pkt| hmac[ [seq_number, pkt].pack("Na*") ] }'

    public
    property_ro :algorithm, 'Struct.new(:cipher, :hmac, :compressor).new'

    include SSH2::Algorithm
    def keys_into_use(keys)
      block_size  Cipher.block_size[algorithm.cipher]

      encrypt     Cipher.get_encrypt(algorithm.cipher, keys)
      decrypt     Cipher.get_decrypt(algorithm.cipher, keys)

      compress    Compressor.get_compress(  algorithm.compressor)
      decompress  Compressor.get_decompress(algorithm.compressor)

      hmac        HMAC.get(algorithm.hmac, &keys[:mac])
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

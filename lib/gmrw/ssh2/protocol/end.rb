# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'timeout'
require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/utils/observable'
require 'gmrw/ssh2/algorithm/cipher'
require 'gmrw/ssh2/algorithm/hmac'
require 'gmrw/ssh2/algorithm/compressor'

module GMRW; module SSH2; module Protocol
  class End < Hash
    include GMRW
    include Utils::Loggable
    include Utils::Observable

    private
    property :service ; alias initialize service= 

    forward [:connection,
             :logger, :die,
             :message_catalog] => :service

    #
    # :section: connection read/write
    #
    EOL = "\r\n"
    READ_SIZE_LIMIT = 35000 # in octets(bytes)
    READ_WAIT_LIMIT = 3600  # in seconds

    def puts(s)
      write(s + EOL) ; s
    end

    def write(data)
      connection.write(data) ; data
    end

    def gets
      timeout(READ_WAIT_LIMIT) do
        (connection.gets or raise EOFError) - /#{EOL}\z/
      end
    rescue EOFError       ; raise "connection EOF"
    rescue Timeout::Error ; raise "connection timeout"
    end

    def read(n)
      timeout(READ_WAIT_LIMIT) do
        n <= 0              ? ""                                      :
        n > READ_SIZE_LIMIT ?                       raise(RangeError) :
                              connection.read(n) or raise(EOFError)
      end
    rescue EOFError       ; die :CONNECTION_LOST, "connection EOF"
    rescue RangeError     ; die :PROTOCOL_ERROR, "read len error:#{n}"
    rescue Timeout::Error ; die :PROTOCOL_ERROR, "connection timeout"
    end

    #
    # :section: messages / sequence number
    #
    property :seq_number, '0'

    def received(message) ; memo(:recv_message, message) ; end
    def sent(message)     ; memo(:send_message, message) ; end

    def memo(label, message)
      info( "--> #{label}[#{seq_number}]: #{message.tag}" )
      debug( "#{message.inspect}" )

      notify_observers(label, message, :seq_number => seq_number)

      seq_number(seq_number.next % 0xffff_ffff)

      self[message.tag] = message
    end

    def forget(*tags)
      tags.each {|tag| delete(tag) }
    end

    #
    # :section: encryption / mac / compression
    #
    include SSH2::Algorithm
    property_rov :block_size, 'Cipher.block_size(algorithm.cipher)'
    property_rov :encrypt,    'Cipher.get_encrypt(algorithm.cipher, @keys)'
    property_rov :decrypt,    'Cipher.get_decrypt(algorithm.cipher, @keys)'
    property_rov :hmac,       'HMAC.get(algorithm.hmac, @keys)'
    property_rov :compress,   'Compressor.get_compress(algorithm.compressor)'
    property_rov :decompress, 'Compressor.get_decompress(algorithm.compressor)'

    property :block_align,'proc {|n| n.align(block_size) }'
    property :compute_mac,'proc {|pkt| hmac[ [seq_number, pkt].pack("Na*") ] }'

    public
    property_ro :algorithm,
        'Struct.new(:cipher, :hmac, :compressor).new("none","none","none")'

    def keys_into_use(keys)
      debug( "keys into use" )

      @keys = keys

      @block_size =
      @encrypt    = @decrypt =
      @hmac       =
      @compress   = @decompress = nil
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

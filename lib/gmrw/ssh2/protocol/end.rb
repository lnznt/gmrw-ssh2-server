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
    def_initialize :service
    forward [:connection, :logger, :die, :message_catalog] => :service

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
    rescue EOFError       ; die "connection EOF"
    rescue Timeout::Error ; die "connection timeout"
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

      seq_number((seq_number + 1) % 0xffff_ffff)

      self[message.tag] = message
    end

    #
    # :section: encryption / mac / compression
    #
    property :keys, 'Hash.new {{}}'

    include SSH2::Algorithm
    property_rwv :block_size, '[Cipher.block_size[algorithm.cipher], 8].max'
    property_rwv :encrypt,    'Cipher.get(algorithm.cipher, keys) {:encrypt}'
    property_rwv :decrypt,    'Cipher.get(algorithm.cipher, keys) {:decrypt}'
    property_rwv :hmac,       'HMAC.get(algorithm.hmac, keys)'
    property_rwv :compress,   'Compressor.get(algorithm.compressor) {:compress}'
    property_rwv :decompress, 'Compressor.get(algorithm.compressor) {:decompress}'

    property_ro :block_align, 'proc {|n| n.align(block_size) }'
    property_ro :compute_mac, 'proc {|pkt| hmac[ [seq_number, pkt].pack("Na*") ] }'

    public
    property_ro :algorithm,
        'Struct.new(:cipher, :hmac, :compressor).new("none","none","none")'

    def keys_into_use(new_keys)
      debug( "new keys into use" )

      keys(new_keys)

      block_size  nil
      encrypt     nil
      decrypt     nil
      hmac        nil
      compress    nil
      decompress  nil
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

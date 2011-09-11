# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'timeout'
require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/algorithm/cipher'
require 'gmrw/ssh2/algorithm/hmac'
require 'gmrw/ssh2/algorithm/compressor'

module GMRW; module SSH2; module Protocol
  class End < Hash
    include GMRW
    include Utils::Loggable

    private
    def_initialize :service
    forward [:connection, :logger, :die, :notify_observers] => :service

    #
    # :section: connection read/write
    #
    def puts(s)
      write(s + "\r\n")
    end

    def write(data)
      connection.write(data)
    end

    def gets
      read(nil) - /\r\n$/
    end

    def read(n)
      size_limit = 35000 # in octets(in bytes)
      wait_limit = 3600  # in seconds

      timeout(wait_limit) do
        n.nil?                      ? (connection.gets    or raise EOFError) :
        (1..size_limit).include?(n) ? (connection.read(n) or raise EOFError) :
        n <= 0                      ? ""                  :  raise(RangeError)
      end
    rescue EOFError       ; die :CONNECTION_LOST, "connection EOF"
    rescue RangeError     ; die :PROTOCOL_ERROR,  "read len error:#{n}"
    rescue Timeout::Error ; die :PROTOCOL_ERROR,  "connection timeout"
    end

    #
    # :section: messages / sequence number
    #
    property :seq_number, '0'

    def seq_count
      seq_number((seq_number + 1) % 32.bit.mask)
    end

    def memo(message)
      self[message.tag] = message.tap {|m| m.seq = seq_number ; seq_count }
    end 

    def received(message)
      memo(message).tap do |m|
        info( "--> received [#{m.seq}]: #{m.tag}" )
        debug( "#{m.inspect}" )

        notify_observers(m.tag, m, {})
      end
    end

    def sent(message)
      memo(message).tap do |m|
        info( "<-- sent [#{m.seq}]: #{m.tag}" )
        debug( "#{m.inspect}" )
      end
    end

    #
    # :section: encryption / mac / compression
    #
    property :keys, 'Hash.new {{}}'

    include SSH2::Algorithm
    property_rwv :block_size, '[Cipher.block_size[algorithm.cipher], 8].max'
    property_rwv :encrypt,    'Cipher.get(algorithm.cipher, keys) {:encrypt}'
    property_rwv :decrypt,    'Cipher.get(algorithm.cipher, keys) {:decrypt}'
    property_rwv :hmac_digest,'HMAC.get(algorithm.hmac, keys)'
    #property_rwv :compress,   'Compressor.get(algorithm.compressor) {:compress}'
    #property_rwv :decompress, 'Compressor.get(algorithm.compressor) {:decompress}'
    property_rwv :compress,   'compressor.compress'
    property_rwv :decompress, 'compressor.decompress'

    property_ro :block_align, 'proc {|n| n.align(block_size) }'
    property_ro :compute_mac, 'proc {|pkt| hmac_digest[ [seq_number, pkt].pack("Na*") ] }'

    public
    property_ro :algorithm,
        'Struct.new(:cipher, :hmac, :compressor).new("none","none","none")'

    property :compressor, 'Compressor.new("none")'
#    property :hmac,       'HMAC.new("none")'

    def keys_into_use(new_keys)
      debug( "new keys into use" )

      keys(new_keys)

      block_size  nil
      encrypt     nil
      decrypt     nil
      hmac_digest        nil
      compress    nil
      decompress  nil
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

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
    property_rwv :block_size,  'cipher.block_size'
    property_rwv :encrypt,     'cipher.encrypt'
    property_rwv :decrypt,     'cipher.decrypt'
    property_rwv :hmac_digest, 'hmac.digest'
    property_rwv :compress,    'compressor.compress'
    property_rwv :decompress,  'compressor.decompress'

    def reset_algorithms
      block_size  nil
      encrypt     nil
      decrypt     nil
      hmac_digest nil
      compress    nil
      decompress  nil
    end

    def compute_mac(packet)
      hmac_digest[ [seq_number, packet].pack("Na*") ]
    end

    public
    property :cipher,     'SSH2::Algorithm::Cipher.new("none")'
    property :hmac,       'SSH2::Algorithm::HMAC.new("none")'
    property :compressor, 'SSH2::Algorithm::Compressor.new("none")'

    def keys_into_use(keys)
      debug( "new keys into use" )

      cipher.keys keys
      hmac.keys   keys

      reset_algorithms
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

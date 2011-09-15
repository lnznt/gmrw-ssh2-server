# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'timeout'
require 'gmrw/extension/all'
require 'gmrw/ssh2/loggable'
require 'gmrw/ssh2/algorithm/cipher'
require 'gmrw/ssh2/algorithm/hmac'
require 'gmrw/ssh2/algorithm/compressor'

module GMRW; module SSH2; module Protocol
  class End < Hash
    include GMRW
    include SSH2::Loggable

    private
    def_initialize :service
    forward [:connection, :logger, :die, :notify] => :service

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
      read(nil).sub(/\r\n$/, '')
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
      info( "#{yield} [#{seq_number}]: #{message.tag}" )
      debug( "#{message.inspect}" )

      seq_count ; self[message.tag] = message
    end 

    def sent(message)
      memo(message){'<-- sent'}
    end

    def received(message)
      memo(message){'--> received'}.tap {|m| notify(m.tag, m) }
    end

    #
    # :section: encryption / mac / compression
    #
    public
    property :keys_and_names, 'Hash.new("none")'
    alias names keys_and_names
    alias keys  keys_and_names

    include SSH2::Algorithm
    property_rwv :cipher,     'Cipher.new(names[:cipher]).tap{|a| a.keys keys}'
    property_rwv :hmac,       'HMAC  .new(names[:hmac  ]).tap{|a| a.keys keys}'
    property_rwv :compressor, 'Compressor.new(names[:compressor])'

    def keys_into_use(k_and_n)
      keys_and_names(k_and_n) ; cipher(nil) ; hmac(nil) ; compressor(nil)
    end

    private
    forward [:block_size, :encrypt, :decrypt] => :cipher
    forward [:digest                        ] => :hmac
    forward [:compress, :decompress         ] => :compressor

    def compute_mac(packet)
      digest[ [seq_number, packet].pack("Na*") ]
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

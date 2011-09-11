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
    public
    property :names, 'Hash.new {"none"}'
    property :keys,  'Hash.new {{}}'

    include SSH2::Algorithm
    property_rwv :cipher,     'Cipher.new(names[:cipher]).tap{|a| a.keys keys}'
    property_rwv :hmac,       'HMAC  .new(names[:hmac  ]).tap{|a| a.keys keys}'
    property_rwv :compressor, 'Compressor.new(names[:compressor])'

    def keys_into_use(keys_and_names)
      keys(keys_and_names)
      names(keys_and_names)

      cipher      nil
      hmac        nil
      compressor  nil
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

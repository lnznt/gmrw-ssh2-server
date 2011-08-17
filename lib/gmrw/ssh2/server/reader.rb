# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/module'
require 'gmrw/extension/string'
require 'gmrw/ssh2/server/side'
require 'gmrw/ssh2/server/exception'
require 'gmrw/ssh2/server/version_string'

class GMRW::SSH2::Server::Reader < GMRW::SSH2::Server::Side
  include GMRW::SSH2

  property_ro :version, 'Server::VersionString.new(gets)'

  def poll_message
    debug( "poll_message ...." )

    message = recv_message

    #debug( "received: #{message[:type]}" )

    #self[message[:type]] = message
  end

  def recv_message(tag)
    debug( "expected message: #{tag}, waiting..." )

    poll_message until self[tag]

    self[tag]
  end

  private
  def recv_message
    payload
  end

  def payload
    packet_length   = read_packet_length
    padding_length  = read_padding_length
    payload         = buffered_read(packet_length.num       -
                                      padding_length.length -
                                      padding_length.num    )
    padding         = buffered_read(padding_length.num)

    debug( "packet_length.length : #{packet_length.length}" )
    debug( "packet_length        : #{packet_length.num}"    )
    debug( "padding_length.length: #{padding_length.length}")
    debug( "padding_length       : #{padding_length.num}"   )
    debug( "payload.length       : #{payload.length}"       )
    debug( "padding.length       : #{padding.length}"       )

    verify!(packet_length, padding_length, payload, padding)

    payload
  end

  def verify!(packet_length, padding_length, payload, padding)
    payload.length > 0 or
        raise Server::PayloadLengthError, "payload.langth: #{payload.length}"

    packet    = [packet_length, padding_length, payload, padding].join
    actual    = packet.length
    expected  = packet_length.length + packet_length.num

    actual == expected or
        raise Server::PacketLengthError, "packet.length:#{actual} != #{expected}"
  end

  def read_packet_length
    buffered_read(4).tap {|s| def s.num ; unpack("N")[0] || 0 ; end }
  end

  def read_padding_length
    buffered_read(1).tap {|s| def s.num ; unpack("C")[0] || 0 ; end }
  end

  def buffered_read(bytes)
    s0, rem0 = (@buffer ||= "") / bytes
    s1       = read((bytes - s0.length).align(block_size))
    s,  rem1 = (s0 + s1) / bytes

    @buffer = rem0 || rem1 || ""
    s
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

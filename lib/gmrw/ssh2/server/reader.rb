# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/server/side'
require 'gmrw/ssh2/server/version_string'
require 'gmrw/ssh2/message'
require 'gmrw/ssh2/message/catalog'

class GMRW::SSH2::Server::Reader < GMRW::SSH2::Server::Side
  include GMRW::SSH2

  property_ro :version, 'Server::VersionString.new(gets)'
  property_ro :message_catalog, 'GMRW::SSH2::Message::Catalog.new'

  def recv_message(tag)
    forget(tag) ; message(tag)
  end

  def message(tag)
    poll_message until self[tag] ; self[tag]
  end

  def poll_message
    info( "poll_message ...." )

    received Message.build(payload) { message_catalog }
  end

  private
  def payload
    packet = [
      pack_len    = buffered_read(4).tap{|s| def s.n; unpack("N")[0]; end },
      padd_len    = buffered_read(1).tap{|s| def s.n; unpack("C")[0]; end },
      zipped_data = buffered_read(pack_len.n - padd_len.length - padd_len.n),
      padding     = buffered_read(padd_len.n),
    ].join

    debug( "packet_length.length   : #{pack_len.length}"    )
    debug( "packet_length          : #{pack_len.n}"         )
    debug( "padding_length.length  : #{padd_len.length}"    )
    debug( "padding_length         : #{padd_len.n}"         )
    debug( "compressed_data.length : #{zipped_data.length}" )
    debug( "padding.length         : #{padding.length}"     )

    mac0 = compute_mac(packet)
    mac1 = read(mac0.length)
    mac0 == mac1 or raise "MAC error: #{mac0} <=> #{mac1}"

    decompress[ zipped_data ]
  end

  def buffered_read(bytes)
    s0, rem0 = (@buffer ||= "") / bytes
    s1       = decrypt[ read((bytes - s0.length).align(block_size)) ]
    s,  rem1 = (s0 + s1) / bytes

    @buffer = rem0 || rem1 || ""
    s
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

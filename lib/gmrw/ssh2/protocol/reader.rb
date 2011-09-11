# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/protocol/end'
require 'gmrw/ssh2/message'

class GMRW::SSH2::Protocol::Reader < GMRW::SSH2::Protocol::End
  include GMRW

  #
  # :section: Protocol Version
  #
  property_ro :version,     'gets'
  property_ro :ssh_version, 'version.mapping(:ssh_version) {/^(SSH-.+?)-/}'

  #
  # :section: Message Catalog
  #
  property_ro :message_catalog, 'SSH2::Message.create_catalog'

  #
  # :section: Receive Methods
  #
  def recv_message(tag)
    delete(tag) ; message(tag)
  end

  def message(tag)
    poll_message until self[tag] ; self[tag]
  end

  def poll_message
    info( "poll_message ...." )

    received SSH2::Message.build(payload) { message_catalog }

  rescue SSH2::Message::ForbiddenMessage => e
    notify_observers([:forbidden], e, :sequence_number => seq_number)
  rescue SSH2::Message::MessageNotFound => e
    notify_observers([:not_found], e, :sequence_number => seq_number)
  end

  #
  # :section: Receive/Unpack Packet
  #
  private
  def payload
    verify! packet = [
      pack_len    = buffered_read(4).tap{|s| def s.n; unpack("N")[0]; end },
      padd_len    = buffered_read(1).tap{|s| def s.n; unpack("C")[0]; end },
      zipped_data = buffered_read(pack_len.n - padd_len.length - padd_len.n),
      padding     = buffered_read(padd_len.n),
    ].join

    decompress[ zipped_data ]
  end

  def verify!(packet)
    mac0 = compute_mac[ packet ]
    mac1 = read(mac0.length)
    mac0 == mac1 or die :MAC_ERROR, "#{mac0.dump} : #{mac1.dump}"
  end

  def buffered_read(bytes)
    s0, rem0 = (@buffer ||= "") / bytes
    s1       = decrypt[ read (bytes - s0.length).align(block_size) ]
    s,  rem1 = (s0 + s1) / bytes

    @buffer = rem0 || rem1 || ""
    s
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

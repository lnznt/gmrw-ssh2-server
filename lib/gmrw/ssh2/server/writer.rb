# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/ssh2/server/side'
require 'gmrw/ssh2/server/version_string'
require 'gmrw/ssh2/message'

class GMRW::SSH2::Server::Writer < GMRW::SSH2::Server::Side
  include GMRW::SSH2

  property_ro :version, 'puts Server::VersionString.new(Server::SSH_VERSION)'

  def message(tag, params={})
    self[tag] || send_message(tag, params)
  end

  def send_message(tag, params={})
    sent Message.create(tag, params).tap {|m| write pack(m.dump) }
  end

  private
  def pack(payload)
    n1    = 4 # packect_length field size
    n2    = 1 # padding_length field size
    m     = 4 # minimum padding size

    zipped_data = compress[ payload ]
    total_len   = (zipped_data.length + n1 + n2 + m).align(block_size)
    pack_len    = total_len - n1
    padd_len    = pack_len - n2 - zipped_data.length 
    padding     = OpenSSL::Random.random_bytes(padd_len)
    packet      = [pack_len, padd_len].pack("NC") + zipped_data + padding

    encrypt[ packet ] + compute_mac(packet)
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

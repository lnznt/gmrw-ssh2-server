# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'thread'
require 'gmrw/extension/all'
require 'gmrw/ssh2/protocol/end'
require 'gmrw/ssh2/message'

class GMRW::SSH2::Protocol::Writer < GMRW::SSH2::Protocol::End
  include GMRW

  #
  # :section: Protocol Version
  #
  property_ro :version, 'SSH2.config.version.tap {|v| puts v }'

  #
  # :section: Send Methods
  #
  def message(tag, params={})
    self[tag] || send_message(tag, params)
  end

  property :q, 'Queue.new'

  def send_message(tag, params={})
    q.push [tag, params]
  end

  def start
    @thread = Thread.fork do
      debug( "writer start" )
      begin
        loop { sent SSH2::Message.create(*q.pop).tap {|m| write pack(m.dump) } }
      rescue => e
        error( "writer error: #{e}" )
      end
    end
  end

  def stop
    debug( "writer stop" )
    @thread.kill rescue nil
  end

  #
  # :section: Pack Message
  #
  private
  def pack(payload)
    n1    = 4 # packect_length field size
    n2    = 1 # padding_length field size
    mn    = 4 # minimum padding size

    zipped_data = compress[ payload ]
    total_len   = (zipped_data.length + n1 + n2 + mn).align(block_size)
    pack_len    = total_len - n1
    padd_len    = pack_len - n2 - zipped_data.length 
    padding     = ssh.random(padd_len)
    packet      = [pack_len, padd_len].pack("NC") + zipped_data + padding

    encrypt[ packet ] + compute_mac(packet)
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/loggable'
require 'gmrw/ssh2/protocol/reader'
require 'gmrw/ssh2/protocol/writer'
require 'gmrw/ssh2/algorithm/kex/dh'

module GMRW::SSH2::Protocol
  class EventError < RuntimeError ; end
end

class GMRW::SSH2::Protocol::Transport
  include GMRW
  include SSH2::Loggable

  #
  # :section: Connection
  #
  def_initialize :connection

  #
  # :section: Reader/Writer
  #
  property_ro :reader, 'SSH2::Protocol::Reader.new(self)'                    ; alias peer  reader
  property_ro :writer, 'SSH2::Protocol::Writer.new(self).tap {|w| w.start }' ; alias local writer

  forward [:poll_message] => :reader
  forward [:send_message] => :writer

  #
  # :section: Event Listener
  #
  property_ro :at_close,  '[]'
  property_ro :listeners, 'Hash.new {|h,key| raise SSH2::Protocol::EventError, "#{key.inspect}" }'

  def register(handlers)
    handlers.each {|event, handler| listeners[event] = handler }
  end

  def notify(event, *a, &b)
    listeners[event].call(*a, &b)
  end

  def cancel(event)
    listeners.delete(event)
  end

  #
  # :section: Start
  #
  def start
    logger.format {|*s| "[#{connection.object_id}] #{s.map(&:to_s) * ': '}" }
    info( "SSH service start" )

    register /NOT FOUND/ => proc {|seq_number|
        send_message :unimplemented, :sequence_number => seq_number
      },
      :disconnect => proc {|message|
        raise "disconnected: #{message[:reason_code]}: #{message[:description]}"
      },
      :kexinit => method(:kexinit_received),
      :newkeys => method(:newkeys_received)

    start_service

  rescue => e
    fatal( "#{e.class}: #{e}" )
    debug{|l| e.backtrace.each {|bt| l << ( bt >> 2 ) } }
    e.call(self) rescue nil

  ensure
    at_close.each(&:call)
    writer.stop
    connection.shutdown
    connection.close
    info( "SSH service terminated" )
  end

  private
  #
  # :section: Protocol Version Exchange
  #
  def protocol_version_exchange
    re = /^SSH-.+?-/
    local.version[re] == peer.version[re] or raise "protocol mismatch"

    info( "local version: #{local.version}" )
    info( "peer  version: #{peer. version}" )
  rescue => e
    connection.puts "#{e}" ; raise
  end

  #
  # :section: Algorithm Negotiation
  #
  private
  def negotiate(label)
    client.message(:kexinit)[label].find   {|a|
    server.message(:kexinit)[label].include?(a)}
  end

  def negotiate!(label)
    negotiate(label) or die :PROTOCOL_ERROR, "algorithm negotiate: #{label}"
  end

  property :names, '{}'

  def kexinit_received(*)
    { :kex_algorithms                           => :kex,
      :server_host_key_algorithms               => :host_key,
      :encryption_algorithms_client_to_server   => :enc_c,
      :encryption_algorithms_server_to_client   => :enc_s,
      :mac_algorithms_client_to_server          => :mac_c,
      :mac_algorithms_server_to_client          => :mac_s,
      :compression_algorithms_client_to_server  => :comp_c,
      :compression_algorithms_server_to_client  => :comp_s,
    }.each {|label, ali| names[ali] = negotiate!(label) }

    debug( "algorithms: #{names.inspect}" )

    register(kex.handlers)
  end

  property_ro :kex, 'SSH2::Algorithm::Kex::DH.new(self)'
  property_ro :session_id, 'kex.hash'

  #
  # :section: Keys into Use
  #
  def newkeys_received(*)
    debug( "new keys into use" )

    key = proc {|salt| proc {|len|
      y =  kex.gen_key(salt + session_id)
      y << kex.gen_key(y) while y.length < len
      y[0...len]
    }}

    client.keys_into_use :cipher     => names[:enc_c ],
                         :hmac       => names[:mac_c ],
                         :compressor => names[:comp_c],
                         :iv         => key["A"],
                         :key        => key["C"],
                         :mac        => key["E"]

    server.keys_into_use :cipher     => names[:enc_s ],
                         :hmac       => names[:mac_s ],
                         :compressor => names[:comp_s],
                         :iv         => key["B"],
                         :key        => key["D"],
                         :mac        => key["F"]
  end

  #
  # :section: Error Handling
  #
  def die(tag, msg="")
    e = RuntimeError.new "#{tag}: #{msg}"
    (class << e ; self ; end).send(:define_method, :call) do |service|
      service.send_message :disconnect, :reason_code => tag,
                                        :description => e.to_s
    end
    raise e
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/utils/observable'
require 'gmrw/ssh2/protocol/reader'
require 'gmrw/ssh2/protocol/writer'
require 'gmrw/ssh2/algorithm/kex/dh'

class GMRW::SSH2::Protocol::Transport
  include GMRW
  include Utils::Loggable
  include Utils::Observable

  #
  # :section: connection
  #
  def_initialize :connection

  #
  # :section: Reader/Writer (=peer/local)
  #
  property_ro :reader, 'SSH2::Protocol::Reader.new(self)' ; alias peer  reader
  property_ro :writer, 'SSH2::Protocol::Writer.new(self)' ; alias local writer

  forward [:poll_message] => :reader
  forward [:send_message] => :writer

  #
  # :section: Starting Transport
  #
  property_ro :at_close, '[]'

  def start
    logger.format {|*s| "[#{connection.object_id}] #{s.map(&:to_s) * ': '}" }
    info( "SSH service start" )

    add_observer(/NOT FOUND/) do |seq_number,|
      send_message :unimplemented, :sequence_number => seq_number
    end

    add_observer(:disconnect) do |message,|
      raise "disconnect message received: #{message[:reason_code]}: #{message[:description]}"
    end

    add_observer(:service_request, &method(:service_request_message_received))
    add_observer(:service_accept,  &method(:service_accept_message_received))

    add_observer(:kexinit,  &method(:kexinit_received))
    add_observer(:newkeys,  &method(:newkeys_received))

    add_observer(:kexdh_init,         &kex.method(:kexdh_init_received))
    add_observer(:kex_dh_gex_request, &kex.method(:kex_dh_gex_request_received))
    add_observer(:kex_dh_gex_init,    &kex.method(:kex_dh_gex_init_received))

    start_service

  rescue => e
    fatal( "#{e.class}: #{e}" )
    debug{|l| e.backtrace.each {|bt| l << ( bt >> 2 ) } }
    e.call(self) rescue nil

  ensure
    at_close.each(&:call)
    connection.shutdown
    connection.close
    info( "SSH service terminated" )
  end

  private
  def service_request_message_received(message, *)
    send_message :unimplemented, :sequence_number => 0
  end

  def service_accept_message_received(message, *)
    send_message :unimplemented, :sequence_number => 0
  end

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
  end

  property_ro :kex, 'SSH2::Algorithm::Kex::DH.new(self)'
  property_ro :session_id, 'kex.h'

  #
  # :section: Keys into use
  #
  def newkeys_received(*)
    debug( "new keys into use" )

    key = proc do |salt| proc {|len|
      y =  kex.gen_key(salt + session_id)
      y << kex.gen_key(y) while y.length < len
      y[0...len]
    } end

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
  # :section: error handling
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

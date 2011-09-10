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
require 'gmrw/ssh2/algorithm/kex'
require 'gmrw/ssh2/algorithm/host_key'

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

  forward [:recv_message, :poll_message, :message_catalog] => :reader
  forward [:send_message,                                ] => :writer

  def client ; raise NotImplementedError, 'client' ; end
  def server ; raise NotImplementedError, 'server' ; end

  #
  # :section: Starting Transport
  #
  property_ro :at_close, '[]'

  def start
    logger.format {|*s| "[#{connection.object_id}] #{s.map(&:to_s) * ': '}" }
    info( "SSH service start" )

    add_observer([:forbidden]) do |e,|
      die :PROTOCOL_ERROR, "forbidden message received: #{e}"
    end

    add_observer([:not_found]) do |e, hint|
      send_message :unimplemented, :sequence_number => hint[:sequence_number]
    end

    add_observer(:disconnect) do |message|
      raise "disconnect message received: #{message[:reason_code]}: #{message[:description]}"
    end

    add_observer(:service_request, &method(:service_request_message_received))
    add_observer(:service_accept,  &method(:service_accept_message_received))

    add_observer(:kexinit,  &method(:start_transport))
    add_observer(:newkeys,  &method(:keys_into_use))

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
  def start_service ; raise NotImplementedError, 'start_service' ; end

  def service_request_message_received(message, *)
    send_message :unimplemented, :sequence_number => message.seq
  end

  def service_accept_message_received(message, *)
    send_message :unimplemented, :sequence_number => message.seq
  end

  #
  # :section: Protocol Version Exchange
  #
  def protocol_version_exchange
    local.ssh_version == peer.ssh_version or raise "protocol mismatch"

    info( "local version: #{local.version}" )
    info( "peer  version: #{peer. version}" )
  rescue => e
    connection.puts "#{e}" ; raise
  end

  #
  # :section: Algorithm Negotiation / Key Exchange
  #
  public
  property :host_key
  private
  attr_reader :session_id
  def start_transport(*)
    negotiate = proc do |name|
      client.message(:kexinit)[name].find   {|a|
      server.message(:kexinit)[name].include?(a)}
    end

    algorithm_kex               = negotiate[ :kex_algorithms                          ]
    algorithm_host_key          = negotiate[ :server_host_key_algorithms              ]
    client.algorithm.cipher     = negotiate[ :encryption_algorithms_client_to_server  ]
    server.algorithm.cipher     = negotiate[ :encryption_algorithms_server_to_client  ]
    client.algorithm.hmac       = negotiate[ :mac_algorithms_client_to_server         ]
    server.algorithm.hmac       = negotiate[ :mac_algorithms_server_to_client         ]
    client.algorithm.compressor = negotiate[ :compression_algorithms_client_to_server ]
    server.algorithm.compressor = negotiate[ :compression_algorithms_server_to_client ]

    debug( "kex                : #{algorithm_kex}"      )
    debug( "host_key           : #{algorithm_host_key}" )
    debug( "client.aligorithms : #{client.algorithm}"   )
    debug( "server.aligorithms : #{server.algorithm}"   )

    kex =    SSH2::Algorithm::Kex.get(algorithm_kex)
    host_key SSH2::Algorithm::HostKey.get(algorithm_host_key)

    message_catalog.kex = algorithm_kex

    secret, hash, = kex.key_exchange(self) ; @session_id ||= hash

    @key = proc do |salt|
      proc do |len|
        y =  kex.digest(secret + hash + salt + @session_id)
        y << kex.digest(secret + hash + y) while y.length < len
        y[0...len]
      end
    end

    send_message :newkeys
  end

  #
  # :section: Keys into use
  #
  def keys_into_use(*)
    client.keys_into_use :iv => @key["A"], :key => @key["C"], :mac => @key["E"]
    server.keys_into_use :iv => @key["B"], :key => @key["D"], :mac => @key["F"]
  end

  #
  # :section: error handling
  #
  def die(tag, msg="")
    e = RuntimeError.new "#{tag}: #{msg}"
    c = class << e ; self ; end
    c.send(:define_method, :call) do |service|
      service.send_message :disconnect, :reason_code => tag,
                                        :description => e.to_s
    end
    raise e
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

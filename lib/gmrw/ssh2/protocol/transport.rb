# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/protocol/reader'
require 'gmrw/ssh2/protocol/writer'
require 'gmrw/ssh2/protocol/exception'
require 'gmrw/ssh2/message/catalog'
require 'gmrw/ssh2/algorithm/kex'
require 'gmrw/ssh2/algorithm/host_key'

class GMRW::SSH2::Protocol::Transport
  include GMRW
  include Utils::Loggable
  include SSH2::Protocol::Exception::Handling

  #
  # :section: resources (Connection and Logger)
  #
  def_initialize :connection

  def logger=(*)
    super.tap {|l| l.format {|*s| "[#{connection.object_id}] #{s.map(&:to_s) * ': '}" }}
  end

  #
  # :section: Reader/Writer (=peer/local)
  #
  property_ro :reader, 'SSH2::Protocol::Reader.new(self)' ; alias peer  reader
  property_ro :writer, 'SSH2::Protocol::Writer.new(self)' ; alias local writer

  forward [:recv_message, :poll_message] => :reader
  forward [:send_message,              ] => :writer

  abstract_method :client
  abstract_method :server

  #
  # :section: Message Catalog
  #
  property_ro :message_catalog, 'SSH2::Message::Catalog.new(logger)'
  forward [:change_algorithm] => :message_catalog

  #
  # :section: Memo (Algorithms)
  #
  property :kex
  property :host_key

  #
  # :section: Starting Transport
  #
  def start
    info( "SSH service start" )

    reader.add_observer(:recv_message, &method(:message_received))
    reader.add_observer(:forbidden_message_error, &method(:message_forbidden))
    reader.add_observer(:message_not_found_error, &method(:message_not_found))

    serve

  rescue SSH2::Protocol::Exception::SSHError => e
    e.call(self)
    fatal( "#{e.class}: #{e}" )
    debug{|l| e.backtrace.each {|bt| l << ( bt >> 2 ) } }

  rescue => e
    connection.puts e.to_s
    fatal( "#{e.class}: #{e}" )
    debug{|l| e.backtrace.each {|bt| l << ( bt >> 2 ) } }

  ensure
    connection.shutdown
    connection.close
    info( "SSH service terminated" )
  end

  private
  abstract_method :serve

  #
  # :section: Message Handlers
  #
  def message_received(*)  ; end
  def message_forbidden(*) ; end
  def message_not_found(*) ; end

  #
  # :section: Protocol Version Exchange
  #
  def protocol_version_exchange
    local.version.compatible?(peer.version) or
                        raise "Protocol mismatch: #{peer.version}"

    info( "local version: #{local.version}" )
    info( "peer  version: #{peer. version}" )
  end

  #
  # :section: Algorithm Negotiation
  #
  def negotiate_algorithms
    algorithm_kex               = negotiate :kex_algorithms
    algorithm_host_key          = negotiate :server_host_key_algorithms
    client.algorithm.cipher     = negotiate :encryption_algorithms_client_to_server
    server.algorithm.cipher     = negotiate :encryption_algorithms_server_to_client
    client.algorithm.hmac       = negotiate :mac_algorithms_client_to_server
    server.algorithm.hmac       = negotiate :mac_algorithms_server_to_client
    client.algorithm.compressor = negotiate :compression_algorithms_client_to_server
    server.algorithm.compressor = negotiate :compression_algorithms_server_to_client

    debug( "kex               : #{algorithm_kex}"               )
    debug( "host_key          : #{algorithm_host_key}"          )
    debug( "client.cipher     : #{client.algorithm.cipher}"     )
    debug( "server.cipher     : #{server.algorithm.cipher}"     )
    debug( "client.hmac       : #{client.algorithm.hmac}"       )
    debug( "server.hmac       : #{server.algorithm.hmac}"       )
    debug( "client.compressor : #{client.algorithm.compressor}" )
    debug( "server.compressor : #{server.algorithm.compressor}" )

    kex       SSH2::Algorithm::Kex.get(algorithm_kex)
    host_key  SSH2::Algorithm::HostKey.get(algorithm_host_key)
    change_algorithm :kex => algorithm_kex
  end

  def negotiate(name)
    client.message(:kexinit)[name].find   {|a|
    server.message(:kexinit)[name].include?(a)}
  end

  #
  # :section: Key Exchange
  #
  def key_exchange
    @secret, @hash, = kex.key_exchange(self) ; @session_id ||= @hash
  end

  def keys_into_use
    key = proc do |salt|
      proc do |len|
        y =  kex.digest(@secret + @hash + salt + @session_id)
        y << kex.digest(@secret + @hash + y)                  while y.length < len
        y[0...len]
      end
    end

    client.keys_into_use :iv => key["A"], :key => key["C"], :mac => key["E"]
    server.keys_into_use :iv => key["B"], :key => key["D"], :mac => key["F"]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

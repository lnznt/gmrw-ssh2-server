# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/alternative/active_support'
require 'gmrw/ssh2/protocol/reader'
require 'gmrw/ssh2/protocol/writer'
require 'gmrw/ssh2/protocol/exception'
require 'gmrw/ssh2/message/catalog'
require 'gmrw/ssh2/algorithm/kex'
require 'gmrw/ssh2/algorithm/host_key'
require 'gmrw/ssh2/algorithm/cipher'
require 'gmrw/ssh2/algorithm/hmac'
require 'gmrw/ssh2/algorithm/compressor'

class GMRW::SSH2::Protocol::Transport
  include GMRW
  include Utils::Loggable
  include SSH2::Protocol::ErrorHandling

  def initialize(conn)
    @connection = conn
  end

  attr_reader :connection

  property_ro :id, 'connection.object_id'

  def logger=(*)
    super.tap {|l| l.format {|*s| "[#{id}] #{s.map(&:to_s) * ': '}" }}
  end

  property_ro :reader, 'SSH2::Protocol::Reader.new(self)'
  property_ro :writer, 'SSH2::Protocol::Writer.new(self)'

  delegate :recv_message, :poll_message, :to => :reader
  delegate :send_message,                :to => :writer

  alias peer  reader
  alias local writer

  property_ro :message_catalog,
                'SSH2::Message::Catalog.new {|ct| ct.logger = logger }'

  delegate :permit, :change_algorithm, :to => :message_catalog

  property_ro :algorithm, 'Struct.new(:kex, :host_key).new'

  property :kex
  property :host_key

  abstract_method :client
  abstract_method :server
  abstract_method :config

  def start
    info( "SSH service start" )

    serve

  rescue => e
    fatal( "#{e.class}: #{e}" )
    debug{|l| e.backtrace.each {|bt| l << ( bt >> 2 ) } }
    e.call(self) rescue nil

  ensure
    connection.shutdown rescue nil
    connection.close    rescue nil
    info( "SSH service terminated" )
  end

  private
  abstract_method :serve

  #
  # :section: Protocol Version Exchange
  #
  def protocol_version_exchange
    local.version.compatible?(peer.version) or
        die :PROTOCOL_VERSION_NOT_SUPPORTED, "#{peer.version}"

    info( "local version: #{local.version}" )
    info( "peer  version: #{peer. version}" )
  end

  #
  # :section: Algorithm Negotiation
  #
  def send_kexinit
    send_message :kexinit, [
        :kex_algorithms,
        :server_host_key_algorithms,
        :encryption_algorithms_client_to_server,
        :encryption_algorithms_server_to_client,
        :mac_algorithms_client_to_server,
        :mac_algorithms_server_to_client,
        :compression_algorithms_client_to_server,
        :compression_algorithms_server_to_client  ].map {|name|
            [name, config.algorithms[name.to_s] ]
        }.to_hash
  end

  def negotiate_algorithms
    algorithm.kex               = negotiate(:kex_algorithms)
    algorithm.host_key          = negotiate(:server_host_key_algorithms)
    client.algorithm.cipher     = negotiate(:encryption_algorithms_client_to_server)
    server.algorithm.cipher     = negotiate(:encryption_algorithms_server_to_client)
    client.algorithm.hmac       = negotiate(:mac_algorithms_client_to_server)
    server.algorithm.hmac       = negotiate(:mac_algorithms_server_to_client)
    client.algorithm.compressor = negotiate(:compression_algorithms_client_to_server)
    server.algorithm.compressor = negotiate(:compression_algorithms_server_to_client)

    debug( "kex               : #{algorithm.kex}"               )
    debug( "host_key          : #{algorithm.host_key}"          )
    debug( "client.cipher     : #{client.algorithm.cipher}"     )
    debug( "server.cipher     : #{server.algorithm.cipher}"     )
    debug( "client.hmac       : #{client.algorithm.hmac}"       )
    debug( "server.hmac       : #{server.algorithm.hmac}"       )
    debug( "client.compressor : #{client.algorithm.compressor}" )
    debug( "server.compressor : #{server.algorithm.compressor}" )

    kex(
      SSH2::Algorithm::Kex.get_kex(algorithm.kex)
    )
    
    host_key(
      SSH2::Algorithm::HostKey.get_host_key(algorithm.host_key, config.host_key_files)
    )
  end

  def negotiate(name)
    client.message(:kexinit)[name].find   {|a|
    server.message(:kexinit)[name].include?(a)}
  end

  #
  # :section: Key Exchange
  #
  def do_kex
    @k, @hash, = kex.start(self)
    @session_id ||= @hash
  end

  def gen_key(salt)
    salt = {
      :client_iv  => "A", :server_iv  => "B",
      :client_key => "C", :server_key => "D",
      :client_mac => "E", :server_mac => "F",
    }[salt] || salt

    digest = proc {|data| host_key.digester.digest(@k + @hash + data) }

    proc do |key_len|
      digest[salt + @session_id][0, key_len].tap do |key|
        key << digest[key][0, key_len - key.length] while key.length < key_len
      end
    end
  end

  def taking_keys_into_use
    SSH2::Algorithm::Cipher.get_cipher(
                mode = (client == local ? :encrypt : :decrypt),
                config.openssl_name[client.algorithm.cipher] || client.algorithm.cipher,
                gen_key(:client_iv),
                gen_key(:client_key)).tap do |cryptor, block_size|
      client.send(mode, cryptor)
      client.block_size = block_size
    end

    SSH2::Algorithm::Cipher.get_cipher(
                mode = (server == local ? :encrypt : :decrypt),
                config.openssl_name[server.algorithm.cipher] || server.algorithm.cipher,
                gen_key(:server_iv),
                gen_key(:server_key)).tap do |cryptor, block_size|
      server.send(mode, cryptor)
      server.block_size = block_size
    end

    client.hmac = SSH2::Algorithm::HMAC.get_hmac(client.algorithm.hmac, gen_key(:client_mac))
    server.hmac = SSH2::Algorithm::HMAC.get_hmac(server.algorithm.hmac, gen_key(:server_mac))

    SSH2::Algorithm::Compressor.get_compressor(
                mode = (client == local ? :compress : :decompress),
                client.algorithm.compressor).tap do |compressor|
      client.send(mode, compressor)
    end

    SSH2::Algorithm::Compressor.get_compressor(
                mode = (server == local ? :compress : :decompress),
                server.algorithm.compressor).tap do |compressor|
      server.send(mode, compressor)
    end
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

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
require 'gmrw/ssh2/algorithm/kex/dh'
require 'gmrw/ssh2/algorithm/host_key/rsa_extension'
require 'gmrw/ssh2/algorithm/cipher/cipher'
require 'gmrw/ssh2/algorithm/hmac/hmac'

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
  # version negotiation
  #
  def negotiate_version
    local.version.compatible?(peer.version) or
        die :PROTOCOL_VERSION_NOT_SUPPORTED, "#{peer.version}"

    info( "local version: #{local.version}" )
    info( "peer  version: #{peer. version}" )
  end

  #
  # algorithm negotiation
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

    kex( choice_kex(algorithm.kex) )
    host_key( choice_host_key(algorithm.host_key) )
  end

  def negotiate(name)
    client.message(:kexinit)[name].find   {|a|
    server.message(:kexinit)[name].include?(a)}
  end

  def choice_kex(kex_name)
    case kex_name
      when 'diffie-hellman-group14-sha1'
        SSH2::Algorithm::Kex::DH.new(OpenSSL::Digest::SHA1,
                                SSH2::Algorithm::OakleyGroup::Group14::G,
                                SSH2::Algorithm::OakleyGroup::Group14::P)

      when 'diffie-hellman-group1-sha1'
        SSH2::Algorithm::Kex::DH.new(OpenSSL::Digest::SHA1,
                                SSH2::Algorithm::OakleyGroup::Group1::G,
                                SSH2::Algorithm::OakleyGroup::Group1::P)
      else
        die :PROTOCOL_ERROR, "unknown kex: #{kex_name}"
    end
  end

  def choice_host_key(host_key_name)
    case host_key_name
      when 'ssh-rsa'
        config.rsa_key.extend(SSH2::Algorithm::HostKey::RSAExtension)

      else
        die :PROTOCOL_ERROR, "unknown host-key: #{host_key_name}"
    end
  end


  #
  # KEX
  #
  def do_kex
    @k, @hash, = kex.start(self)
    @session_id ||= @hash
  end

  def gen_key(salt)
    digest = proc {|data| host_key.digester.digest(@k + @hash + data) }

    proc do |key_len|
      key  = digest[salt + @session_id][0, key_len]
      key << digest[key][0, key_len - key.length] while key.length < key_len
      key
    end
  end

  def client_iv_gen      ; gen_key("A") ; end
  def server_iv_gen      ; gen_key("B") ; end
  def client_key_gen     ; gen_key("C") ; end
  def server_key_gen     ; gen_key("D") ; end
  def client_mac_key_gen ; gen_key("E") ; end
  def server_mac_key_gen ; gen_key("F") ; end

  def shift_to_secure_mode
    SSH2::Algorithm::Cipher.get_cipher(mode = (client == local ? :encrypt : :decrypt),
                                       client.algorithm.cipher,         
                                       client_iv_gen,
                                       client_key_gen).tap do |cryptor, block_size|
      client.send(mode, cryptor)
      client.block_size = block_size
    end

    SSH2::Algorithm::Cipher.get_cipher(mode = (server == local ? :encrypt : :decrypt),
                                       server.algorithm.cipher,
                                       server_iv_gen,
                                       server_key_gen).tap do |cryptor, block_size|
      server.send(mode, cryptor)
      server.block_size = block_size
    end

    client.hmac = SSH2::Algorithm::HMAC.get_hmac(client.algorithm.hmac, client_mac_key_gen)
    server.hmac = SSH2::Algorithm::HMAC.get_hmac(server.algorithm.hmac, server_mac_key_gen)
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

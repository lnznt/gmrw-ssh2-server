# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/protocol/transport'
require 'gmrw/ssh2/server/config'

# KEX
require 'openssl'
require 'gmrw/alternative/active_support'

class GMRW::SSH2::Server::Service < GMRW::SSH2::Protocol::Transport
  include GMRW

  property_ro :client, :peer
  property_ro :server, :local
  property_ro :config, 'SSH2::Server::Config'

  def serve
    negotiate_version

    permit(1..49) { true }
    permit(:service_request) { false }
    permit(:service_accept)  { false }

    send_kexinit and negotiate_algorithms

    permit(:kexinit) { false }
    change_algorithm :kex => algorithm.kex

    do_kex

    permit(:service_request) { true }
    permit(:kexinit)         { true }


=begin
    c_cipher = OpenSSL::Cipher.new(openssl_name(client.algorithm.cipher))

    debug( "client is receiver.") if client == reader

    c_cipher.send(client == reader ? :decrypt : :encrypt)
    c_cipher.padding = 0
    c_cipher.iv  = gen_key("A", c_cipher.iv_len )
    c_cipher.key = gen_key("C", c_cipher.key_len)

    client.send(client == reader ? :decrypt : :encrypt) {|data| data.present? ? c_cipher.update(data) : data }
    client.block_size = c_cipher.block_size
=end

    OpenSSL::Cipher.new(openssl_name(client.algorithm.cipher)).tap do |cipher|

      cipher.send(client == reader ? :decrypt : :encrypt)
      cipher.padding = 0
      cipher.iv  = gen_key("A", cipher.iv_len )
      cipher.key = gen_key("C", cipher.key_len)

      client.send(client == reader ? :decrypt : :encrypt) {|data| data.present? ? cipher.update(data) : data }
      client.block_size = cipher.block_size
    end




    s_cipher = OpenSSL::Cipher.new(openssl_name(server.algorithm.cipher))

    s_cipher.send(server == reader ? :decrypt : :encrypt)
    s_cipher.padding = 0
    s_cipher.iv  = gen_key("B", s_cipher.iv_len )
    s_cipher.key = gen_key("D", s_cipher.key_len)

    server.send(server == reader ? :decrypt : :encrypt) {|data| data.present? ? s_cipher.update(data) : data }
    server.block_size = s_cipher.block_size

    c_mac_digester = OpenSSL::Digest::MD5
    c_mac_key_len  = 16
    c_mac_len      = 16
    c_mac_key      = gen_key("E", c_mac_key_len)

    client.hmac do |data|
      OpenSSL::HMAC.digest(c_mac_digester.new, c_mac_key, data)[0, c_mac_len]
    end
    
    s_mac_digester = OpenSSL::Digest::MD5
    s_mac_key_len  = 16
    s_mac_len      = 16
    s_mac_key      = gen_key("F", s_mac_key_len)

    server.hmac do |data|
      OpenSSL::HMAC.digest(s_mac_digester.new, s_mac_key, data)[0, s_mac_len]
    end
    
    permit(50..79) { true }

    poll_message #TRY!!

    send_message :service_accept, :service_name => 'ssh-userauth' # DUMMY
              
    poll_message #TRY!! ---> maybe message(50) unimplemented error





    ###poll_message # DUMMY
    #
    # TODO :
    #
    die :BY_APPLICATION, "SORRY!! Not implement yet."
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

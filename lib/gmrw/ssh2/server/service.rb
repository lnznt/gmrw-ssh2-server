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
require 'gmrw/ssh2/algorithm/oakley_group'
require 'gmrw/ssh2/message/key/key/ssh_rsa'

class GMRW::SSH2::Server::Service < GMRW::SSH2::Protocol::Transport
  include GMRW

  property_ro :client, :peer
  property_ro :server, :local
  property_ro :config, 'SSH2::Server::Config'

  # KEX
  attr_accessor :dh, :digester

  def serve
    permit(1..49) { true }
    permit(:service_request) { false }
    permit(:service_accept)  { false }

    send_kexinit and negotiate_algorithms

    permit(:kexinit) { false }
    change_algorithm :kex => algorithm.kex

    #*************************************
    #  DUMMY
    #*************************************

    #poll_message # DUMMY
    #
    # KEX : DH-group14-sha1 / RSA *****
    #
    @dh = OpenSSL::PKey::DH.new
    group = SSH2::Algorithm::OakleyGroup[:group14]
    @digester = OpenSSL::Digest::SHA1
    @host_key = config.rsa_key
    @key_digester = OpenSSL::Digest::SHA1


    dh.g = group.G
    dh.p = group.P
    dh.priv_key = OpenSSL::BN.rand(secret_key_bit = 512)
    dh.generate_key! until pub_key_ok?(dh.pub_key.to_i)

    send_message :kexdh_reply, 
          :host_key_and_certificates => k_s,
          :f                         => f,
          :signature_of_hash         => s

    send_message :newkeys
    recv_message :newkeys

    [k, hash]
    session_id = hash

    permit(:service_request) { true }
    permit(:kexinit)         { true }


    #
    # IV / Key generate
    #
    openssl_name = proc do |nm| 
      {
        'aes128-cbc'  => 'aes-128-cbc'
      }[nm]
    end
  
    key_digest = proc {|data| @key_digester.digest(k + hash + data) }

    gen_key = proc do |salt, key_len|
      key =  key_digest[salt + session_id][0, key_len]
      debug( "KEY is short!!") if key.length < key_len
      debug( "KEY is OK!!") unless key.length < key_len
      key << key_digest[key][0, key_len - key.length] while key.length < key_len
      key
    end

    c_cipher = OpenSSL::Cipher.new(openssl_name[client.algorithm.cipher])

    debug( "client is receiver.") if client == reader

    c_cipher.send(client == reader ? :decrypt : :encrypt)
    c_cipher.padding = 0
    c_cipher.iv  = gen_key["A", c_cipher.iv_len ]
    c_cipher.key = gen_key["C", c_cipher.key_len]

    client.send(client == reader ? :decrypt : :encrypt) {|data| data.present? ? c_cipher.update(data) : data }
    client.block_size = c_cipher.block_size

    s_cipher = OpenSSL::Cipher.new(openssl_name[server.algorithm.cipher])

    s_cipher.send(server == reader ? :decrypt : :encrypt)
    s_cipher.padding = 0
    s_cipher.iv  = gen_key["B", s_cipher.iv_len ]
    s_cipher.key = gen_key["D", s_cipher.key_len]

    server.send(server == reader ? :decrypt : :encrypt) {|data| data.present? ? s_cipher.update(data) : data }
    server.block_size = s_cipher.block_size

    #s_cipher = OpenSSL::Cipher.new(server.algorithm.cipher)

    c_mac_digester = OpenSSL::Digest::MD5
    c_mac_key_len  = 16
    c_mac_len      = 16
    c_mac_key      = gen_key["E", c_mac_key_len]

    client.hmac do |data|
      OpenSSL::HMAC.digest(c_mac_digester.new, c_mac_key, data)[0, c_mac_len]
    end
    
    s_mac_digester = OpenSSL::Digest::MD5
    s_mac_key_len  = 16
    s_mac_len      = 16
    s_mac_key      = gen_key["F", s_mac_key_len]

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

  private # KEX
  def pub_key_ok?(pub_key=dh.pub_key.to_i)
     (0...dh.p).include?(pub_key) && pub_key.count_bit > 1
  end

  def v_c ; client.version                  ; end
  def v_s ; server.version                  ; end

  def i_c ; client[:kexinit].dump           ; end
  def i_s ; server[:kexinit].dump           ; end

  def k_s
#    debug(" host_key: e: #{@host_key.e} ")
#    debug(" host_key: n: #{@host_key.n} ")
#    debug(" host_key:    #{@host_key.to_text} ")

    @key = SSH2::Message::Key.create(:ssh_rsa, :e => @host_key.e,
                                              :n => @host_key.n)
    debug(" key:    #{@key} ")
    @key.dump
  end

  def e   ; client.message(:kexdh_init)[:e] ; end
  def f   ; dh.pub_key                      ; end

  def shared_secret  ; dh.compute_key(e)     ; end

  def k
      @k0 ||= OpenSSL::BN.new(shared_secret, 2)
      @k ||= SSH2::Message::Field.encode(:mpint, @k0)
  end

  def hash ; digester.digest(h)            ; end
  def s
      s = @host_key.sign(@key_digester.new, hash)

      SSH2::Message::Field.pack(  [:string, 'ssh-rsa'],
                                  [:string, s])
      
                   
=begin
      def self.sign(data)
        s = private_key.sign self.digester.new, data
        s = encode_signature s
        to_sshsignature s
      end
=end
  end

  def h
      SSH2::Message::Field.pack( [:string, v_c],
                                 [:string, v_s],
                                 [:string, i_c],
                                 [:string, i_s],
                                 [:string, k_s],
                                 [:mpint , e  ],
                                 [:mpint , f  ]) + k
  end    

end

# vim:set ts=2 sw=2 et fenc=utf-8:

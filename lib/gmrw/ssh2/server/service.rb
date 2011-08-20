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

    #*************************************
      DUMMY
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

    permit(:service_request) { true }
    permit(:kexinit)         { true }

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
    debug(" host_key: e: #{@host_key.e} ")
    debug(" host_key: n: #{@host_key.n} ")
    debug(" host_key:    #{@host_key.to_text} ")

    @key = SSH2::Message::Key.create(:ssh_rsa, :e => @host_key.e,
                                              :n => @host_key.n)
    debug(" key:    #{@key} ")
    @key.dump
  end

  def e   ; client.message(:kexdh_init)[:e] ; end
  def f   ; dh.pub_key                      ; end

  def shared_secret  ; dh.compute_key(e)     ; end

  def k
      k0 = OpenSSL::BN.new(shared_secret, 2)
      SSH2::Message::Field.encode(:mpint, k0)
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

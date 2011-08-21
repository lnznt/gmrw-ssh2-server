# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/alternative/active_support'
require 'gmrw/ssh2/algorithm/oakley_group'

module GMRW; module SSH2; module Algorithm ; module Kex
  class DH
    include GMRW
    include Utils::Loggable

    def start(service)
      @service = service

      send_message :kexdh_reply,
            :host_key_and_certificates => k_s,
            :f                         => f,
            :signature_of_hash         => s

      send_message :newkeys
      recv_message :newkeys

      [k, hash]
    end

    private
    delegate :logger,
             :send_message,
             :recv_message,
             :client,
             :server,
             :host_key,     :to => :@service
            
    property_ro :dh, 'OpenSSL::PKey::DH.new' 
    property    :digester

    def initialize(dh_digester, dh_g, dh_p, secret_key_bit=512)
      digester(dh_digester)

#      group = SSH2::Algorithm::OakleyGroup[dh_group]
      #dh.g = group::G
      #dh.p = group::P
      dh.g, dh.p = dh_g, dh_p
      dh.priv_key = OpenSSL::BN.rand(secret_key_bit)
      dh.generate_key! until dh_pub_key_ok?
    end

    private
    def dh_pub_key_ok?(pub_key=dh.pub_key.to_i)
       (0...dh.p).include?(pub_key) && pub_key.count_bit > 1
    end

    def v_c ; client.version                  ; end
    def v_s ; server.version                  ; end

    def i_c ; client[:kexinit].dump           ; end
    def i_s ; server[:kexinit].dump           ; end

    def k_s ; host_key.dump                   ; end

    def e   ; client.message(:kexdh_init)[:e] ; end
    def f   ; dh.pub_key                      ; end

    def shared_secret
      @shared_secret ||= dh.compute_key(e)
    end

    def k
      SSH2::Message::Field.encode(:mpint, OpenSSL::BN.new(shared_secret, 2))
    end

    def hash ; digester.digest(h)           ; end
    def s    ; host_key.to_signature(hash)  ; end

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
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

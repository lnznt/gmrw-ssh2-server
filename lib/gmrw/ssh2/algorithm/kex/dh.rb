# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/algorithm/oakley_group'
require 'gmrw/ssh2/message'

module GMRW; module SSH2; module Algorithm ; module Kex
  class DH
    include GMRW
    include Utils::Loggable

    private
    forward [:logger,
             :send_message,
             :recv_message,
             :client,
             :server,
             :host_key     ] => :@service
            
    property_ro :dh, 'OpenSSL::PKey::DH.new' 
    property    :digester
    forward     [:digest] => :digester

    def initialize(dh_digester, dh_g=nil, dh_p=nil, secret_key_bits=512)
      digester(dh_digester)

      @g, @p           = dh_g, dh_p
      @secret_key_bits = secret_key_bits
    end

    def ready(dh_g=nil, dh_p=nil, secret_key_bits=nil)
      dh.g        = dh_g || @g
      dh.p        = dh_p || @p
      dh.priv_key = OpenSSL::BN.rand(secret_key_bits || @secret_key_bits)
      dh.generate_key! until dh_pub_key_ok?
    end

    def dh_pub_key_ok?(pub_key=dh.pub_key.to_i)
       (0...dh.p).include?(pub_key) && pub_key.count_bit > 1
    end

    public
    def start(service)
      @service = service

      ready

      send_message :kexdh_reply,
            :host_key_and_certificates => k_s,
            :f                         => f,
            :signature_of_hash         => s

      send_message :newkeys
      recv_message :newkeys

      [k, hash]
    end

    private
    property_ro :k_s, 'host_key.dump'
    property_ro :e,   'client.message(:kexdh_init)[:e]'
    property_ro :f,   'dh.pub_key'

    property_ro :shared_secret, 'dh.compute_key(e)'
    property_ro :hash,          'digest(h)'
    property_ro :s,             'host_key.to_signature(hash)'

    include SSH2::Message
    def k
      Field.encode(:mpint, OpenSSL::BN.new(shared_secret, 2))
    end

    def h
      Field.pack([:string, v_c = client.version       ],
                 [:string, v_s = server.version       ],
                 [:string, i_c = client[:kexinit].dump],
                 [:string, i_s = server[:kexinit].dump],
                 [:string, k_s                        ],
                 [:mpint , e                          ],
                 [:mpint , f                          ]) + k
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

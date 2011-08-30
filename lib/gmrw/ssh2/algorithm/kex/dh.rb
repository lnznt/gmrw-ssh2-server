# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/message'

module GMRW; module SSH2; module Algorithm ; module Kex
  class DH
    include GMRW
    include Utils::Loggable

    private
    forward [:logger, :die,
             :send_message, :recv_message, :use_message,
             :client, :server,
             :host_key     ] => :@service
            
    forward [:encode, :pack] => SSH2::Message::Field

    #
    # :section: digester / group / dh
    #
    private
    property    :initialize

    property_ro :digester, 'OpenSSL::Digest.const_get(initialize[:digester])'
    forward    [:digest] => :digester

    property_ro :groups,   'SSH2.config.oakley_group'
    property_ro :group,    'groups[initialize[:group]]'

    property_ro :dh,       'OpenSSL::PKey::DH.new' 

    #
    # :section: protocol framework
    #
    private
    def ready
      dh.g = group[:g]
      dh.p = OpenSSL::BN.new(*group[:p])

      dh.generate_key! until (0...dh.p).include?(dh.pub_key) &&
                             dh.pub_key.to_i.count_bit > 1
    end

    public
    def key_exchange(service)
      @service = service

      use_message :kex => messages
      ready ; agree

      [k, h]
    end

    #
    # :section: protocol parameters
    #
    private
    property_ro :v_c,                  'client.version'
    property_ro :v_s,                  'server.version'
    property_ro :i_c,                  'client[:kexinit].dump'
    property_ro :i_s,                  'server[:kexinit].dump'
    property_ro :k_s,                  'host_key.dump'
    property_ro :f,                    'dh.pub_key'

    property_ro :shared_secret,        'dh.compute_key(e)'
    property_ro :binary_shared_secret, 'OpenSSL::BN.new(shared_secret, 2)'
    property_ro :k,                    'encode(:mpint, binary_shared_secret)'

    property_ro :h,                    'digest(h0)'
    property_ro :s,                    'host_key.sign_and_pack(h)'

    #
    # :section: DH Key Agreement
    #
    private
    property_ro :messages, '[:kexdh_init]'

    def agree
      send_message :kexdh_reply,
            :host_key_and_certificates => k_s,
            :f                         => f,
            :signature_of_hash         => s
    end

    property_ro :e, 'client.message(:kexdh_init)[:e]'

    def h0
      pack([:string, v_c ],
           [:string, v_s ],
           [:string, i_c ],
           [:string, i_s ],
           [:string, k_s ],
           [:mpint , e   ],
           [:mpint , f   ]) + k
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

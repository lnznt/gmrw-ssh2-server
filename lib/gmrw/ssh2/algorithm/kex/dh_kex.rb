# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/utils/loggable'

module GMRW; module SSH2; module Algorithm ; class Kex
  class DHKex
    include GMRW
    include Utils::Loggable

    property :host_key

    def config(&block)
      instance_eval(&block) ; self
    end

    private
    def_initialize :service
    forward [:logger, :die,
             :send_message,
             :client, :server] => :service

    property :digester, '"sha1"'
    property :group

    #
    # :section: digester / group / dh
    #
    property_ro :openssl_digester, 'OpenSSL::Digest.new(digester)'
    forward    [:digest] => :openssl_digester

    property_ro :oakley_groups,   'SSH2.config.oakley_group'
    property_ro :oakley_group,    'oakley_groups[group]'

    property_ro :dh,       %-
      OpenSSL::PKey::DH.new.tap do |d|
        d.g = oakley_group[:g]
        d.p = OpenSSL::BN.new(*oakley_group[:p])

        d.generate_key! until (0...d.p).include?(d.pub_key) &&
                              d.pub_key.to_i.bit.count > 1
      end
    -

    #
    # :section: protocol framework
    #
    public
    def key_exchange
      agree ; [k, h]
    end

    #
    # :section: protocol parameters
    #
    private
    property_ro :v_c,              'client.version'
    property_ro :v_s,              'server.version'
    property_ro :i_c,              'client[:kexinit].dump'
    property_ro :i_s,              'server[:kexinit].dump'
    property_ro :k_s,              'host_key.dump'
    property_ro :f,                'dh.pub_key'

    property_ro :shared_secret,    'dh.compute_key(e).to.bn(:binary)'
    property_ro :k,                'shared_secret.ssh.encode(:mpint)'

    property_ro :h,                'digest(h0)'
    property_ro :s,                'host_key.sign_and_pack(h)'

    #
    # :section: DH Key Agreement
    #
    def agree
      send_message :kexdh_reply,
            :host_key_and_certificates => k_s,
            :f                         => f,
            :signature_of_hash         => s
    end

    property_ro :e, 'client.message(:kexdh_init)[:e]'

    def h0
      [ [:string, v_c ],
        [:string, v_s ],
        [:string, i_c ],
        [:string, i_s ],
        [:string, k_s ],
        [:mpint , e   ],
        [:mpint , f   ] ].ssh.pack + k
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

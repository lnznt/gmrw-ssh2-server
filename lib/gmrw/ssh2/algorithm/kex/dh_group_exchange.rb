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
require 'gmrw/ssh2/algorithm/kex/dh'

module GMRW::SSH2::Algorithm::Kex
  # see RFC4419 for details
  class DH_GroupExchange < DH
    def start(service)
      @service = service

      ready n

      send_message :key_dh_gex_group, :p => dh.p, :g => dh.g

      send_message :key_dh_gex_reply,
                          :host_key_and_certificates => k_s,
                          :f                         => f,
                          :signature_of_hash         => s

      send_message :newkeys
      recv_message :newkeys

      [k, hash]
    end

    private
    def ready(bits)
      group = bits == 2048 ? SSH2::Algorithm::OakleyGroup::Group14 :
              bits == 1024 ? SSH2::Algorithm::OakleyGroup::Group1  :
                             (raise "DH_GEX: #{bits} bits")

      super(group::G, group::P, group::BITS)
    end

    private
    property_ro :k_s, 'host_key.dump'

    property_ro :max, 'client.message(:key_dh_gex_request)[:max]'
    property_ro :n,   'client.message(:key_dh_gex_request)[:n  ]'
    property_ro :min, 'client.message(:key_dh_gex_request)[:min]'

    property_ro :e,   'client.message(:key_dh_gex_init)[:e]'
    property_ro :f,   'dh.pub_key'

    property_ro :shared_secret, 'dh.compute_key(e)'
    property_ro :hash,          'digester.digest(h)'
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
                 [:uint32, min                        ],
                 [:uint32, n                          ],
                 [:uint32, max                        ],
                 [:mpint , dh.p                       ],
                 [:mpint , dh.g                       ],
                 [:mpint , e                          ],
                 [:mpint , f                          ]) + k
    end
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

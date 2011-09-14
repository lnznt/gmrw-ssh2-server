# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/ssh2/algorithm/pub_key'

module GMRW; module SSH2; module Algorithm ; class Kex
  class DH
    include GMRW

    def gen_key(s)
      digest(k + h + s)
    end

    def hash
      h
    end

    def handlers
      {
        :kexdh_init          => method(:kexdh_init_received),
        :kex_dh_gex_request  => method(:kex_dh_gex_request_received),
        :kex_dh_gex_init     => method(:kex_dh_gex_init_received),
      }
    end

    private
    def_initialize :service
    forward [:logger, :die,
             :send_message,
             :client, :server,
             :names] => :service

    #
    # :section: digester / group / dh
    #
    property_ro :host_key,      'SSH2::Algorithm::PubKey.host_key(names[:host_key])'

    property_ro :digester_name, 'names[:kex][/sha\d+$/]'
    property_ro :digester,      'OpenSSL::Digest.new(digester_name)'
    forward    [:digest] => :digester

    property_ro :group_tag,     '(names[:kex][/group\d+/]||"_").to_sym'
    property_ro :oakley_groups, 'SSH2.config.oakley_group'
    property_ro :oakley_group,  'oakley_groups[group_tag]'
    property_ro :group,         'oakley_group || choice_group'

    def choice_group
      a = oakley_groups.each_value.find {|g| g[:bits] == n }
      b = oakley_groups.each_value.find {|g| (min..max).include?(g[:bits]) }

      (a || b) or raise "DH Group Error: n:#{n}, min..max#{min}..#{max}"
    end

    property_ro :dh, %-
      OpenSSL::PKey::DH.new.tap do |d|
        d.g = group[:g]
        d.p = OpenSSL::BN.new(*group[:p])

        d.generate_key! until (0...d.p).include?(d.pub_key) &&
                              d.pub_key.to_i.bit.count > 1
      end
    -

    #
    # :section: protocol parameters
    #
    property_ro :v_c,           'client.version'
    property_ro :v_s,           'server.version'
    property_ro :i_c,           'client[:kexinit].dump'
    property_ro :i_s,           'server[:kexinit].dump'
    property_ro :k_s,           'host_key.dump'
    property_ro :f,             'dh.pub_key'

    property_ro :shared_secret, 'dh.compute_key(e).to.bn(:binary)'
    property_ro :k,             'shared_secret.ssh.encode(:mpint)'

    property_ro :h,             'digest(h0)'
    property_ro :s,             'host_key.sign_and_pack(h)'

    property :e
    property :h0

    #
    # :section: DH Key Agreement
    #
    def kexdh_init_received(message)
      h0([[ :string, v_c            ],
          [ :string, v_s            ],
          [ :string, i_c            ],
          [ :string, i_s            ],
          [ :string, k_s            ],
          [ :mpint,  e(message[:e]) ],
          [ :mpint,  f              ]].ssh.pack + k)

      send_message :kexdh_reply,
            :host_key_and_certificates => k_s,
            :f                         => f,
            :signature_of_hash         => s

      send_message :newkeys
    end

    #
    # :section: DH GEX Key Agreement
    #
    property :max
    property :n
    property :min

    def kex_dh_gex_request_received(message)
      max(message[:max])
      n(  message[:n  ])
      min(message[:min])

      send_message :kex_dh_gex_group, :p => dh.p, :g => dh.g
    end

    def kex_dh_gex_init_received(message)
      h0([[ :string, v_c            ],
          [ :string, v_s            ],
          [ :string, i_c            ],
          [ :string, i_s            ],
          [ :string, k_s            ],
          [ :uint32, min            ],
          [ :uint32, n              ],
          [ :uint32, max            ],
          [ :mpint , dh.p           ],
          [ :mpint , dh.g           ],
          [ :mpint , e(message[:e]) ],
          [ :mpint , f              ]].ssh.pack + k)

      send_message :kex_dh_gex_reply,
            :host_key_and_certificates => k_s,
            :f                         => f,
            :signature_of_hash         => s

      send_message :newkeys
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

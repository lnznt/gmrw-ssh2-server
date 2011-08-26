# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/algorithm/kex/dh'

module GMRW; module SSH2; module Algorithm ; module Kex
  class DHGex < DH
    private
    def group
      a = groups.each_value.find {|g| g[:bits] == n }
      b = groups.each_value.find {|g| (min..max).include?(g[:bits]) }

      (a || b) or raise "DH Group Error: n:#{n}, min..max#{min}..#{max}"
    end

    #
    # :section: DH Key Agreement
    #
    def agree
      send_message :kex_dh_gex_group, :p => dh.p, :g => dh.g

      send_message :kex_dh_gex_reply,
            :host_key_and_certificates => k_s,
            :f                         => f,
            :signature_of_hash         => s
    end

    property_ro :max, 'client.message(:kex_dh_gex_request)[:max]'
    property_ro :n,   'client.message(:kex_dh_gex_request)[:n  ]'
    property_ro :min, 'client.message(:kex_dh_gex_request)[:min]'

    property_ro :e,   'client.message(:kex_dh_gex_init)[:e]'

    def h0
      pack([:string, v_c  ],
           [:string, v_s  ],
           [:string, i_c  ],
           [:string, i_s  ],
           [:string, k_s  ],
           [:uint32, min  ],
           [:uint32, n    ],
           [:uint32, max  ],
           [:mpint , dh.p ],
           [:mpint , dh.g ],
           [:mpint , e    ],
           [:mpint , f    ]) + k
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

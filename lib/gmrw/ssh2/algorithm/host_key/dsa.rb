# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'

module GMRW; module SSH2; module Algorithm; module HostKey
  class DSAKey < OpenSSL::PKey::DSA
    def dump
      [ [:string, 'ssh-dss' ],
        [:mpint,  p         ],
        [:mpint,  q         ],
        [:mpint,  g         ],
        [:mpint,  pub_key   ] ].ssh.pack
    end

    def sign_and_pack(data)
      a1 = OpenSSL::ASN1.decode(sign('dss1', data))
      s  = a1.value.map {|v| v.value.to_s(2).rjust(20, "\0") }.join

      s.length == 40 or raise "bad sig size"

      [ [:string, 'ssh-dss'], [:string, s] ].ssh.pack
    end

    def unpack_and_verify(s, data)
      id, sig, = s.ssh.unpack [:string, :string]

      sig = sig.unpack("a20 a20").map {|v| v.to.mpi.to.der }.to.der

      id == 'ssh-dss' && verify('dss1', sig, data)
    end

    class << self
      def create(data)
        id, p_, q, g, pub_key, = data.ssh.unpack [:string, :mpint, :mpint, :mpint, :mpint]

        id == 'ssh-dss' or raise "not DSA key"

        new.tap {|key| key.p, key.q, key.g, key.pub_key = p_, q, g, pub_key }
      end

      def load(s)
        new open(s)
      end
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

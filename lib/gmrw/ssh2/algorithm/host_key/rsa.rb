# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'

module GMRW; module SSH2; module Algorithm; module HostKey
  class RSAKey < OpenSSL::PKey::RSA
    def dump
      [ [:string, 'ssh-rsa'],
        [:mpint,  e        ],
        [:mpint,  n        ] ].ssh.pack
    end

    def sign_and_pack(data)
      [ [:string, 'ssh-rsa'], [:string, sign('sha1', data)] ].ssh.pack
    end

    def unpack_and_verify(s, data)
      id, sig, = s.ssh.unpack [:string, :string]

      id == 'ssh-rsa' && verify('sha1', sig, data)
    end

    class << self
      def create(data)
        id, e, n, = data.ssh.unpack [:string, :mpint, :mpint]

        id == 'ssh-rsa' or raise "not RSA key"

        new.tap {|key| key.e, key.n = e, n }
      end

      def load(s)
        new open(s)
      end
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

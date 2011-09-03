# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/ssh2/field'

module GMRW; module SSH2; module Algorithm; module HostKey
  class RSAKey < OpenSSL::PKey::RSA
    def dump
      GMRW::SSH2::Field.pack [:string, 'ssh-rsa'],
                             [:mpint,  e        ],
                             [:mpint,  n        ]
    end

    def sign_and_pack(data)
      s = sign('sha1', data)
      GMRW::SSH2::Field.pack [:string, 'ssh-rsa'],
                             [:string, s        ]
    end

    def unpack_and_verify(s, data)
      vs, rem = GMRW::SSH2::Field.unpack(s, [:string, :string])
      id, sig = vs

      id == 'ssh-rsa' && verify('sha1', sig, data) && rem.empty?
    end

    class << self
      def create(data)
        vs, = GMRW::SSH2::Field.unpack(data, [:string, :mpint, :mpint])
        id, e, n = vs

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

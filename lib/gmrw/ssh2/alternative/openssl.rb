# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/ssh2/field'

module GMRW::Extension
  mixin OpenSSL::PKey::RSA do
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

    def unpack_and_verify(s)
      vs, rem = GMRW::SSH2::Field.unpack(s, [:string, :string])
      id, sig = vs

      id == 'ssh-rsa' && verify('sha1', sig, s) && rem.empty?
    end
  end

  mixin OpenSSL::PKey::DSA do
    def dump
      GMRW::SSH2::Field.pack [:string, 'ssh-dss' ],
                             [:mpint,  p         ],
                             [:mpint,  q         ],
                             [:mpint,  g         ],
                             [:mpint,  pub_key   ]
    end

    def sign_and_pack(data)
      a1 = OpenSSL::ASN1.decode(sign('dss1', data))
      s  = a1.value.map {|v| v.value.to_s(2).rjust(20, "\0") }.join

      s.length == 40 or raise OpenSSL::PKey::DSAError, "bad sig size"

      GMRW::SSH2::Field.pack [:string, 'ssh-dss'],
                             [:string, s        ]
    end

    def unpack_and_verify(s)
      vs, rem = GMRW::SSH2::Field.unpack(s, [:string, :string])
      id, sig = vs

      a1  = sig.unpack("a20 a20").map {|v| OpenSSL::ASN1::Integer.new(OpenSSL::BN.new(v, 2)) }
      sig = OpenSSL::ASN1::Sequence.new(a1).to_der

      id == 'ssh-dss' && verify('dss1', sig, s) && rem.empty?
    end
  end
end

class OpenSSL::PKey::RSA
  class << self
    def parse(data)
      vs, = GMRW::SSH2::Field.unpack(data, [:string, :mpint, :mpint])
      id, e, n = vs

      id == 'ssh-rsa' or raise OpenSSL::PKey::RSAError, "not RSA key"

      OpenSSL::PKey::RSA.new.tap {|key| key.e, key.n = e, n }
    end
  end
end

class OpenSSL::PKey::DSA
  class << self
    def parse(data)
      vs, = GMRW::SSH2::Field.unpack(data, [:string, :mpint, :mpint, :mpint, :mpint])
      id, p_, q, g, pub_key = vs

      id == 'ssh-dss' or raise OpenSSL::PKey::DSAError, "not DSA key"

      OpenSSL::PKey::DSA.new.tap {|key| key.p, key.q, key.q, key.pub_key = p_, q, g, pub_key }
    end
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

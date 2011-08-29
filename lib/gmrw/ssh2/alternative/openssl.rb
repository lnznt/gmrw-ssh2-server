# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/ssh2/message/field'

module GMRW::Extension
  mixin OpenSSL::PKey::RSA do
    def dump
      GMRW::SSH2::Message::Field.pack [:string, 'ssh-rsa'],
                                      [:mpint,  e        ],
                                      [:mpint,  n        ]
    end

    def sign_and_pack(data)
      s = sign('sha1', data)
      GMRW::SSH2::Message::Field.pack [:string, 'ssh-rsa'],
                                      [:string, s        ]
    end
  end

  mixin OpenSSL::PKey::DSA do
    def dump
      GMRW::SSH2::Message::Field.pack [:string, 'ssh-dss' ],
                                      [:mpint,  p         ],
                                      [:mpint,  q         ],
                                      [:mpint,  g         ],
                                      [:mpint,  pub_key   ]
    end

    def sign_and_pack(data)
      s  = sign('dss1', data)
      ss = OpenSSL::ASN1.decode(s).value.map {|v| v.value.to_s(2).rjust(20, "\0") }

      !ss.find {|v| v.length > 20 } or raise OpenSSL::PKey::DSAError, "bad sig size"

      GMRW::SSH2::Message::Field.pack [:string, 'ssh-dss'],
                                      [:string, ss.join  ]
    end
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/ssh2/message/field'

module GMRW; module SSH2; module Algorithm ; module HostKey
  module DSAExtension
    include GMRW

    property :digester, 'OpenSSL::Digest::DSS1'

    def dump
      SSH2::Message::Field.pack [:string, 'ssh-dss'           ],
                                [ :mpint, p                   ],
                                [ :mpint, q                   ],
                                [ :mpint, g                   ],
                                [ :mpint, priv_key || pub_key ]
    end

    def sign(*a)
      a.count < 2 ? sign(digester.new, a[0]) : super
    end

    def to_signature(*a)
      a1 = OpenSSL::ASN1.decode(sign(*a))

      s = a1.value.map  {|v| v.value.to_s(2)}
                  .each {|v| v.length <= 20 or raise OpenSSL::PKey::DSAError, "bad sig size"}
                  .map  {|v| "\0" * (20 - v.length) + v}
                  .join

      SSH2::Message::Field.pack [:string, 'ssh-dss'],
                                [:string, s        ]
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

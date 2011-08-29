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

#    property_ro :digester, 'OpenSSL::Digest::DSS1'

    def dump
      SSH2::Message::Field.pack [:string, 'ssh-dss' ],
                                [:mpint,  p         ],
                                [:mpint,  q         ],
                                [:mpint,  g         ],
                                [:mpint,  pub_key   ]
    end

    def sign(s, extra=nil)
      extra ? super : sign('dss1', s)
    end

    def dumped_sign(*a)
      # DER expression => Ruby's object
      ss = OpenSSL::ASN1.decode(sign(*a)).value.map {|v| v.value.to_s(2).rjust(20, "\0") }

      !ss.find {|v| v.length > 20 } or raise OpenSSL::PKey::DSAError, "bad sig size"

      SSH2::Message::Field.pack [:string, 'ssh-dss'],
                                [:string, ss.join  ]
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

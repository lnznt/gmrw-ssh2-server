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
  module RSAExtension
    include GMRW

    property_ro :digester, 'OpenSSL::Digest::SHA1'

    def dump
      SSH2::Message::Field.pack [:string, 'ssh-rsa'],
                                [:mpint,  e        ],
                                [:mpint,  n        ]
    end

    def sign(s, extra=nil)
      extra ? super : sign(digester.new, s)
    end

    def dumped_sign(*a)
      SSH2::Message::Field.pack [:string, 'ssh-rsa'],
                                [:string, sign(*a) ]
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

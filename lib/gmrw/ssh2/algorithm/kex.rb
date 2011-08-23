# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/ssh2/algorithm/oakley_group'
require 'gmrw/ssh2/algorithm/kex/dh'
require 'gmrw/ssh2/algorithm/kex/dh_group_exchange'

module GMRW; module SSH2; module Algorithm
  module Kex
    include GMRW
    extend self

    def [](kex_name)
      case kex_name
        when 'diffie-hellman-group14-sha1'
          SSH2::Algorithm::Kex::DH.new(OpenSSL::Digest::SHA1,
                                SSH2::Algorithm::OakleyGroup::Group14::G,
                                SSH2::Algorithm::OakleyGroup::Group14::P,
                                SSH2::Algorithm::OakleyGroup::Group14::BITS)

        when 'diffie-hellman-group1-sha1'
          SSH2::Algorithm::Kex::DH.new(OpenSSL::Digest::SHA1,
                                SSH2::Algorithm::OakleyGroup::Group1::G,
                                SSH2::Algorithm::OakleyGroup::Group1::P,
                                SSH2::Algorithm::OakleyGroup::Group1::BITS)

        when 'diffie-hellman-group-exchange-sha1'
          SSH2::Algorithm::Kex::DH_GroupExchange.new(OpenSSL::Digest::SHA1)

        when 'diffie-hellman-group-exchange-sha256'
          SSH2::Algorithm::Kex::DH_GroupExchange.new(OpenSSL::Digest::SHA256)

        else
          raise "unknown kex #{kex_name}"
      end
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

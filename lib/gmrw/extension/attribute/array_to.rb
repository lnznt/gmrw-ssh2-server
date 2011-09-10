# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/attribute'

class GMRW::Extension::Attribute
  module ArrayTo
    def asn1
      OpenSSL::ASN1::Sequence.new(this)
    end

    def der
      asn1.to_der
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'

module GMRW::Extension
  mixin Array do
    def to_hash
      Hash[ *flatten(1) ]
    end

    def cons(*a)
      Array(a) + self
    end

    def rjust(len, pad=nil)
      cons *(len > length ? [pad] * (len - length) : [])
    end

    def to_asn1
      OpenSSL::ASN1::Sequence.new(self)
    end

    def to_der
      to_asn1.to_der
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

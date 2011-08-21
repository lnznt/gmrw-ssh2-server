# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'

module GMRW; module SSH2; module Algorithm
  module HMAC
    extend self
    def get_hmac(hmac_name, key_gen)
      md5 = OpenSSL::Digest::MD5

      case hmac_name
        when 'hmac-md5'
          key = key_gen[key_len=16]
          proc {|data| OpenSSL::HMAC.digest(md5.new, key, data)[0, mac_len=16]}

        else
          raise 
      end
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

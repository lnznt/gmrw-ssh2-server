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
      spec = case hmac_name
        when 'hmac-md5'
          {:digester => OpenSSL::Digest::MD5,  :key_len => 16, :mac_len => 16}

        when 'hmac-md5-96'
          {:digester => OpenSSL::Digest::MD5,  :key_len => 16, :mac_len => 12}

        when 'hmac-sha1'
          {:digester => OpenSSL::Digest::SHA1, :key_len => 20, :mac_len => 20}

        when 'hmac-sha1-96'
          {:digester => OpenSSL::Digest::SHA1, :key_len => 20, :mac_len => 12}

        else
          raise "unknown hmac: #{hmac_name}"
      end

      key = key_gen[spec[:key_len]]
      proc do|data|
        OpenSSL::HMAC.digest(spec[:digester].new, key, data)[0, spec[:mac_len]]
      end
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

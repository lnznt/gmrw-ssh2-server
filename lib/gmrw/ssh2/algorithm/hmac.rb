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

    def get(name)
      (d, key_len, mac_len = {
        'hmac-md5'     => [OpenSSL::Digest::MD5,  16, 16],
        'hmac-md5-96'  => [OpenSSL::Digest::MD5,  16, 12],
        'hmac-sha1'    => [OpenSSL::Digest::SHA1, 20, 20],
        'hmac-sha1-96' => [OpenSSL::Digest::SHA1, 20, 12],
      }[name]) or raise "unknown hmac: #{name}"

      key = yield(key_len)

      proc {|s| OpenSSL::HMAC.digest(d.new, key, s)[0, mac_len] }
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

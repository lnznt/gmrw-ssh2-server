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

    def get(name, keys)
      (digester, key, mac_len = case name
        when 'hmac-md5'    ; ['md5',  keys[:mac][16], 16]
        when 'hmac-md5-96' ; ['md5',  keys[:mac][16], 12]
        when 'hmac-sha1'   ; ['sha1', keys[:mac][20], 20]
        when 'hmac-sha1-96'; ['sha1', keys[:mac][20], 12]
        when 'none'        ; return proc {|s| "" }
      end) or raise "unknown hmac: #{name}"

      proc {|s| OpenSSL::HMAC.digest(digester, key, s)[0...mac_len] }
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

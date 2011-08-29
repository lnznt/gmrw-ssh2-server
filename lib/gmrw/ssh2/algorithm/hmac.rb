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

    def get(name, *a)
      name == 'none' ? proc {|s| "" } : get_mac(name, *a)
    end

    private
    def get_mac(name, keys)
      m = {
        'hmac-md5'     => {:digester => 'md5',  :key_len => 16, :mac_len => 16},
        'hmac-md5-96'  => {:digester => 'md5',  :key_len => 16, :mac_len => 12},
        'hmac-sha1'    => {:digester => 'sha1', :key_len => 20, :mac_len => 20},
        'hmac-sha1-96' => {:digester => 'sha1', :key_len => 20, :mac_len => 12},
      }[name] or raise "unknown hmac: #{name}"

      key = keys[:mac][m[:key_len]]

      proc {|s| OpenSSL::HMAC.digest(m[:digester], key, s)[0...m[:mac_len]] }
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

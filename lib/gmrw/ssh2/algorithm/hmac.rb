# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/extension/all'

module GMRW; module SSH2; module Algorithm
  class HMAC
    def_initialize :name
    property       :keys, 'Hash.new{{}}'

    property_ro :digest, 'proc {|s| hmac.digest(digester, key, s)[0...mac_len] }'

    private
    property_ro :hmac,     'digester ? OpenSSL::HMAC : none'
    property_ro :none,     'Class.new { def digest(*) ; "" ; end }.new'

    property_ro :key,      'keys[:mac][key_len]'

    property_ro :digester, 'spec(name)[:digester]'
    property_ro :key_len,  'spec(name)[:key_len]'
    property_ro :mac_len,  'spec(name)[:mac_len]'

    def spec(name)
      {
        'hmac-md5'     => { :digester => 'md5',
                            :key_len  => 16,
                            :mac_len  => 16,
        },
        'hmac-md5-96'  => { :digester => 'md5',
                            :key_len  => 16,
                            :mac_len  => 12,
        },
        'hmac-sha1'    => { :digester => 'sha1',
                            :key_len  => 20,
                            :mac_len  => 20,
        },
        'hmac-sha1-96' => { :digester => 'sha1',
                            :key_len  => 20,
                            :mac_len  => 12,
        },
      }[name] || {:key_len=>0, :mac_len=>0}
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

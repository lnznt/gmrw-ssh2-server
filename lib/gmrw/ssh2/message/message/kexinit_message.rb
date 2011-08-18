# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
#  a1 = %w[  diffie-hellman-group-exchange-sha256
#            diffie-hellman-group-exchange-sha1
#            diffie-hellman-group14-sha1
#            diffie-hellman-group1-sha1  ]

  a1 = %w[ diffie-hellman-group14-sha1 ]

  a2 = %w[  ssh-rsa ssh-dss ]

  a3 = %w[  aes128-cbc
            aes256-cbc
            aes192-cbc
            blowfish-cbc
            cast128-cbc
            3des-cbc  ]

  a4 = %w[  hmac-sha1
            hmac-sha1-96
            hmac-md5
            hmac-md5-96 ]

  a5 = %w[  none zlib ]

  rnd = proc { OpenSSL::Random.random_bytes(16).unpack("C*") }

  def_message :kexinit, [
    [ :byte,      :type                                    , 20 ],
    [ 16,         :cookie                                  ,rnd ],
    [ :namelist,  :kex_algorithms                          , a1 ],
    [ :namelist,  :server_host_key_algorithms              , a2 ],
    [ :namelist,  :encryption_algorithms_client_to_server  , a3 ],
    [ :namelist,  :encryption_algorithms_server_to_client  , a3 ],
    [ :namelist,  :mac_algorithms_client_to_server         , a4 ],
    [ :namelist,  :mac_algorithms_server_to_client         , a4 ],
    [ :namelist,  :compression_algorithms_client_to_server , a5 ],
    [ :namelist,  :compression_algorithms_server_to_client , a5 ],
    [ :namelist,  :languages_client_to_server                   ],
    [ :namelist,  :languages_server_to_client                   ],
    [ :boolean,   :first_kex_packet_follows                     ],
    [ :uint32,    :reserved                                     ],
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:

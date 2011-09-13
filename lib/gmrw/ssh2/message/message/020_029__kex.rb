# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  def_message :kexinit, [
    [ :byte,     :type                                  , 20 ],
    [ 16,        :cookie                                     ],

    [ :namelist, :kex_algorithms,                          %w[
                     diffie-hellman-group-exchange-sha256
                     diffie-hellman-group-exchange-sha1
                     diffie-hellman-group14-sha1
                     diffie-hellman-group1-sha1             ]],
 
    [ :namelist, :server_host_key_algorithms,              %w[
                     ssh-dss
                     ssh-rsa                                ]],

    [ :namelist, :encryption_algorithms_client_to_server,  %w[
                     aes128-cbc
                     aes256-cbc
                     aes192-cbc
                     blowfish-cbc
                     cast128-cbc
                     3des-cbc                               ]],

    [ :namelist, :encryption_algorithms_server_to_client,  %w[
                     aes128-cbc
                     aes256-cbc
                     aes192-cbc
                     blowfish-cbc
                     cast128-cbc
                     3des-cbc                               ]],

    [ :namelist, :mac_algorithms_client_to_server,         %w[
                     hmac-sha1
                     hmac-sha1-96
                     hmac-md5
                     hmac-md5-96                            ]],

    [ :namelist, :mac_algorithms_server_to_client,         %w[ 
                     hmac-sha1
                     hmac-sha1-96
                     hmac-md5
                     hmac-md5-96                            ]],

    [ :namelist, :compression_algorithms_client_to_server, %w[
                    none
                    zlib                                    ]],

    [ :namelist, :compression_algorithms_server_to_client, %w[
                    none
                    zlib                                    ]],

    [ :namelist, :languages_client_to_server                 ],
    [ :namelist, :languages_server_to_client                 ],
    [ :boolean,  :first_kex_packet_follows                   ],
    [ :uint32,   :reserved                                   ],
  ]

  def_message :newkeys, [
    [ :byte, :type, 21 ],
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:

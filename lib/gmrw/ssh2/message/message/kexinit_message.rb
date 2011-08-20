# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/ssh2/algorithm'
require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  rnd = proc { OpenSSL::Random.random_bytes(16).unpack("C*") }

  def_message :kexinit, [
    [ :byte,      :type                                    , 20 ],
    [ 16,         :cookie                                  ,rnd ],
    [ :namelist,  :kex_algorithms                               ],
    [ :namelist,  :server_host_key_algorithms                   ],
    [ :namelist,  :encryption_algorithms_client_to_server       ],
    [ :namelist,  :encryption_algorithms_server_to_client       ],
    [ :namelist,  :mac_algorithms_client_to_server              ],
    [ :namelist,  :mac_algorithms_server_to_client              ],
    [ :namelist,  :compression_algorithms_client_to_server      ],
    [ :namelist,  :compression_algorithms_server_to_client      ],
    [ :namelist,  :languages_client_to_server                   ],
    [ :namelist,  :languages_server_to_client                   ],
    [ :boolean,   :first_kex_packet_follows                     ],
    [ :uint32,    :reserved                                     ],
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:

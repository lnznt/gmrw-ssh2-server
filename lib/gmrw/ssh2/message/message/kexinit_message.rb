# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  rnd = proc { OpenSSL::Random.random_bytes(16).unpack("C*") }

  kex = proc { GMRW::SSH2.config.algorithms[:kex_algorithms] }
  hky = proc { GMRW::SSH2.config.algorithms[:server_host_key_algorithms] }
  ecs = proc { GMRW::SSH2.config.algorithms[:encryption_algorithms_client_to_server] }
  esc = proc { GMRW::SSH2.config.algorithms[:encryption_algorithms_server_to_client] }
  mcs = proc { GMRW::SSH2.config.algorithms[:mac_algorithms_client_to_server] }
  msc = proc { GMRW::SSH2.config.algorithms[:mac_algorithms_server_to_client] }
  ccs = proc { GMRW::SSH2.config.algorithms[:compression_algorithms_client_to_server] }
  csc = proc { GMRW::SSH2.config.algorithms[:compression_algorithms_server_to_client] }

  def_message :kexinit, [
    [ :byte,      :type                                    , 20 ],
    [ 16,         :cookie                                  ,rnd ],
    [ :namelist,  :kex_algorithms                          ,kex ],
    [ :namelist,  :server_host_key_algorithms              ,hky ],
    [ :namelist,  :encryption_algorithms_client_to_server  ,ecs ],
    [ :namelist,  :encryption_algorithms_server_to_client  ,esc ],
    [ :namelist,  :mac_algorithms_client_to_server         ,mcs ],
    [ :namelist,  :mac_algorithms_server_to_client         ,msc ],
    [ :namelist,  :compression_algorithms_client_to_server ,ccs ],
    [ :namelist,  :compression_algorithms_server_to_client ,csc ],
    [ :namelist,  :languages_client_to_server                   ],
    [ :namelist,  :languages_server_to_client                   ],
    [ :boolean,   :first_kex_packet_follows                     ],
    [ :uint32,    :reserved                                     ],
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:

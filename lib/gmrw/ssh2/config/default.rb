# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

module GMRW; module SSH2; module Config
  module Default
    extend self

    def algorithms
      {
        "kex_algorithms" => %w[ diffie-hellman-group-exchange-sha256
                                diffie-hellman-group-exchange-sha1
                                diffie-hellman-group14-sha1
                                diffie-hellman-group1-sha1 ],

        "server_host_key_algorithms" => %w[ ssh-rsa ssh-dss ],
        
        "encryption_algorithms_client_to_server" => %w[ aes128-cbc
                                                        aes256-cbc
                                                        aes192-cbc
                                                        blowfish-cbc
                                                        cast128-cbc
                                                        3des-cbc ],

        "encryption_algorithms_server_to_client" => %w[ aes128-cbc
                                                        aes256-cbc
                                                        aes192-cbc
                                                        blowfish-cbc
                                                        cast128-cbc
                                                        3des-cbc ],

        "mac_algorithms_client_to_server" => %w[ hmac-sha1
                                                 hmac-sha1-96
                                                 hmac-md5
                                                 hmac-md5-96 ],

        "mac_algorithms_server_to_client" => %w[ hmac-sha1
                                                 hmac-sha1-96
                                                 hmac-md5
                                                 hmac-md5-96 ],
        
        "compression_algorithms_client_to_server" => %w[none zlib],
        "compression_algorithms_server_to_client" => %w[none zlib],
      }
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

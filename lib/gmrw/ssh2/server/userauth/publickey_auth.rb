# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/algorithm/host_key'
require 'gmrw/ssh2/field'

module GMRW; module SSH2; module Server; class UserAuth ; class PublicKeyAuth
  include GMRW
  include Utils::Loggable

  def_initialize :service
  forward [ :logger, :die,
            :send_message,
            :session_id,
            :welcome, :please_retry] => :service
  
  property_ro :users, 'SSH2.config.users'

  def authenticate(message)
=begin
    algo = message[:pk_algorithm]
    blob = message[:pk_key_blob]
    sig  = message[:with_pk_signature] && message[:pk_signature]

    debug( "publickey auth: algorithm = #{algo}" )
    debug( "publickey auth: sig       = #{sig}" )

    key = SSH2::Algorithm::HostKey.algorithms[algo].create(blob) rescue nil
    debug( "publickey auth: rsa key   = #{key}" )

    ok = key && sig && key.unpack_and_verify(sig, SSH2::Field.pack(
                                                    [:string,  session_id                 ],
                                                    [:byte,    message[:type             ]],
                                                    [:string,  message[:user_name        ]],
                                                    [:string,  message[:service_name     ]],
                                                    [:string,  message[:method_name      ]],
                                                    [:boolean, message[:with_ok_signature]],
                                                    [:boolean, message[:pk_algorithm     ]],
                                                    [:boolean, message[:pk_key_blob      ]]))
    debug( "publickey auth: #{ok}" )

    ok   ? welcome(message) :
    sig  ? please_retry     :
           send_message(:userauth_pk_ok, :pk_algorithm => algo,
                                         :pk_key_blob  => blob)
=end
please_retry
  end
end; end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/algorithm/host_key'

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
    algo = message[:pk_algorithm]
    blob = message[:pk_key_blob]
    sig  = message[:with_pk_signature] && message[:pk_signature]

    debug( "publickey auth: algorithm = #{algo}" )
    debug( "publickey auth: sig       = #{sig}" )

    key = SSH2::Algorithm::HostKey.algorithms[algo].create(blob) rescue nil
    debug( "publickey auth: key       = #{key}" )

    ok = key && sig && key.unpack_and_verify(sig, [ [:string,  session_id                 ],
                                                    [:byte,    message[:type             ]],
                                                    [:string,  message[:user_name        ]],
                                                    [:string,  message[:service_name     ]],
                                                    [:string,  message[:method_name      ]],
                                                    [:boolean, message[:with_pk_signature]],
                                                    [:string,  message[:pk_algorithm     ]],
                                                    [:string,  message[:pk_key_blob      ]] ].ssh.pack)
    debug( "publickey auth: #{ok}" )

    ok   ? welcome(message) :
    sig  ? please_retry     :
           send_message(:userauth_pk_ok, :pk_algorithm => algo,
                                         :pk_key_blob  => blob)
  end
end; end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

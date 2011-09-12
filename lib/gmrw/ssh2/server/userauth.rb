# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/algorithm/host_key'
require 'gmrw/ssh2/server/userauth/user'

module GMRW; module SSH2; module Server; class UserAuth
  include GMRW
  include Utils::Loggable

  def_initialize :service
  forward [:logger, :die,
           :session_id, :send_message, :message_catalog] => :service
  
  property_ro :user, 'User.new(self)'

  def start(service_name=nil)
    debug( "userauth in service: #{service_name}" )

    service.add_observer(:userauth_request) do |message,|
      user.name_check!(message)

      case message_catalog.auth = message[:method_name]
        when 'password'  ; password_authenticate(message)
        when 'publickey' ; publickey_authenticate(message)
        else             ; please_retry
      end
    end

    service_name && send_message(:service_accept, :service_name => service_name)
  end

  #
  # :section: reply message
  #
  def welcome(message)
    service.notify_observers(message[:service_name])

    send_message :userauth_banner,
                 :message => "\r\nWelcome to GMRW SSH2 Server\r\n\r\n"
    send_message :userauth_success
  end

  def please_retry
    user.count_check!

    send_message :userauth_failure,
                 :auths_can_continue => SSH2.config.authentication
  end

  #
  # :section: authenticate
  #
  property_ro :users, 'SSH2.config.users'

  def password_authenticate(message)
    user = message[:user_name]
    pass = message[:old_password]
    chpw = message[:with_new_password]

    ok = !chpw && (users[user] || {})[:password] == pass

    debug( "password auth : #{ok}" )

    ok ? welcome(message) : please_retry
  end

  def publickey_authenticate(message)
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

    ok          ? welcome(message) :
    key && !sig ? send_message(:userauth_pk_ok,
                               :pk_algorithm => algo, :pk_key_blob  => blob) :
                  please_retry
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

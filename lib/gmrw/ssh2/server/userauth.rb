# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/loggable'
require 'gmrw/ssh2/algorithm/pub_key'
require 'gmrw/ssh2/server/service'

class GMRW::SSH2::Server::UserAuth
  include GMRW
  include SSH2::Loggable

  def start
    debug( "userauth in service" )

    service.register :userauth_request         => method(:userauth_request_received),
                    {:userauth => 'password' } => method(:password_authenticate),
                    {:userauth => 'publickey'} => method(:publickey_authenticate)
  end

  private
  def_initialize :service
  forward [:logger, :die, :send_message] => :service

  #
  # :section: Time & Count
  #
  property :time,  'Time.now + 600'
  property :count, '20'

  def time_check!
    (time - Time.now) > 0 or die :NO_MORE_AUTH_METHODS_AVAILABLE, "timeout"
  end

  def count_check!
    count(count - 1) >= 0 or die :NO_MORE_AUTH_METHODS_AVAILABLE, "retry count over"
  end

  #
  # :section: userauth_request
  #
  property :user_name
  property :service_name
  property :method_name

  def userauth_request_received(message)
    time_check!

    user_name    message[:user_name   ]
    service_name message[:service_name]
    method_name  message[:method_name ]; service.names[:userauth] = method_name

    service.notify({:userauth => method_name}, message)

  rescue SSH2::Protocol::EventError => e
    debug( "userauth: event error: #{e}" )
    please_retry
  end

  #
  # :section: welcome / retry
  #
  property_ro :banner, '"\r\nWelcome to GMRW SSH2 Server\r\n\r\n"'

  def welcome
    service.notify(service_name)

    send_message :userauth_banner, :message => banner
    send_message :userauth_success
  end

  property_ro :auths_list, 'SSH2.config.authentication'

  def please_retry
    count_check!

    send_message :userauth_failure, :auths_can_continue => auths_list
  end

  #
  # :section: authentication
  #
  property_ro :users, 'SSH2.config.users'

  def password_authenticate(message)
    pass = message[:old_password]
    chpw = message[:with_new_password]

    ok = !chpw && (users[user_name] || {})[:password] == pass

    debug( "password auth : #{ok}" )

    ok ? welcome : please_retry
  end

  def publickey_authenticate(message)
    algo = message[:pk_algorithm]
    blob = message[:pk_key_blob]
    sig  = message[:with_pk_signature] && message[:pk_signature]

    debug( "publickey auth: algorithm = #{algo}" )
    debug( "publickey auth: sig       = #{sig}" )

    key = SSH2::Algorithm::PubKey.algorithms[algo].create(blob) rescue nil
    debug( "publickey auth: key       = #{key}" )

    ok = key && sig && key.unpack_and_verify(sig, [ [:string,  service.session_id         ],
                                                    [:byte,    message[:type             ]],
                                                    [:string,  message[:user_name        ]],
                                                    [:string,  message[:service_name     ]],
                                                    [:string,  message[:method_name      ]],
                                                    [:boolean, message[:with_pk_signature]],
                                                    [:string,  message[:pk_algorithm     ]],
                                                    [:string,  message[:pk_key_blob      ]] ].ssh.pack)
    debug( "publickey auth: #{ok}" )

    ok          ? welcome                                                                    :
    key && !sig ? send_message(:userauth_pk_ok, :pk_algorithm => algo, :pk_key_blob => blob) :
                  please_retry
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

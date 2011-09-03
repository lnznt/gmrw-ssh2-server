# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'

module GMRW; module SSH2; module Server; class UserAuth ; class PasswordAuth
  include GMRW
  include Utils::Loggable

  def_initialize :service
  forward [ :logger, :die,
            :send_message,
            :welcome, :please_retry] => :service
  
  property_ro :users, 'SSH2.config.users'

  def authenticate(message)
    user = message[:user_name]
    pass = message[:old_password]
    chpw = message[:with_new_password]

    ok = !chpw && (users[user] || {})[:password] == pass

    debug( "password auth : #{ok}" )

    ok ? welcome(message) : please_retry
  end
end; end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

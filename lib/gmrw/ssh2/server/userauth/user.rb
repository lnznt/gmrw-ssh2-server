# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
#require 'gmrw/ssh2/server/userauth/password_auth'

module GMRW; module SSH2; module Server; class UserAuth
  class User
    include GMRW
    include Utils::Loggable

    def_initialize :service
    forward [:logger, :die] => :service

    property :user_name
    property :service_name

    property_ro  :time_limit, '600'  # in seconds
    property_rwv :time,  'Time.now'
    property_rwv :count, '20'

    def change_user(info)
      user_name    info[:user_name]
      service_name info[:service_name]
      time         nil
      count        nil
    end

    def same_user?(info)
      user_name    == info[:user_name   ] &&
      service_name == info[:service_name]
    end

    def time_check!
      ((t = Time.now) - time) < time_limit or
                die :NO_MORE_AUTH_METHODS_AVAILABLE, "timeout"
      time t
    end

    def count_check!
      count > 0 or die :NO_MORE_AUTH_METHODS_AVAILABLE, "retry count over"

      count(count - 1)
    end

    def name_check!(info)
      same_user?(info) ? time_check! : change_user(info)
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

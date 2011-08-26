# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/ssh2/algorithm/kex/dh'
require 'gmrw/ssh2/algorithm/kex/dh_gex'

module GMRW; module SSH2; module Algorithm
  module Kex
    include GMRW
    extend self

    def get(name)
      params = {
        'diffie-hellman-group1-sha1'           => {:group => :group1,  :digester => :SHA1  },
        'diffie-hellman-group14-sha1'          => {:group => :group14, :digester => :SHA1  },
        'diffie-hellman-group-exchange-sha1'   => {                    :digester => :SHA1  },
        'diffie-hellman-group-exchange-sha256' => {                    :digester => :SHA256},
      }[name] or raise "unknown kex #{name}"

      (params[:group] ? DH : DHGex).new(params)
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

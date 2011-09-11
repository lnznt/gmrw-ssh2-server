# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/algorithm/kex/dh_kex'
require 'gmrw/ssh2/algorithm/kex/dh_gex'

module GMRW; module SSH2; module Algorithm
  class Kex
    forward [:digest] => :dh

    def start(names)
      dh(spec(names[:kex]).call).host_key SSH2::Algorithm::HostKey.get(names[:host_key])

      message_catalog.kex = names[:kex] ; dh.key_exchange
    end

    private
    def_initialize :service
    forward [:logger, :die,
             :send_message,
             :recv_message,
             :client, :server,
             :message_catalog ] => :service

    property :dh

    def spec(name)
      {
        'diffie-hellman-group1-sha1'           => proc { DHKex.new(self) { group(:group1)  }    },
        'diffie-hellman-group14-sha1'          => proc { DHKex.new(self) { group(:group14) }    },
        'diffie-hellman-group-exchange-sha1'   => proc { DHGex.new(self)                        },
        'diffie-hellman-group-exchange-sha256' => proc { DHGex.new(self) { digester('sha256') } },
      }[name] or raise "kex error: #{name}"
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

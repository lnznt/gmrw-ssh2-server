# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/algorithm/kex/dh'
require 'gmrw/ssh2/algorithm/kex/dh_gex'

module GMRW; module SSH2; module Algorithm
  module Kex
    include GMRW
    extend self

    def get(name)
      case name
        when 'diffie-hellman-group1-sha1'          ; DH.new    :digester => :SHA1, :group => :group1
        when 'diffie-hellman-group14-sha1'         ; DH.new    :digester => :SHA1, :group => :group14
        when 'diffie-hellman-group-exchange-sha1'  ; DHGex.new :digester => :SHA1
        when 'diffie-hellman-group-exchange-sha256'; DHGex.new :digester => :SHA256
      end or raise "unknown kex #{name}"
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

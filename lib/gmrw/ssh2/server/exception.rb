# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/server/constants'

module GMRW::SSH2::Server
  class PeerVersionError   < StandardError ; end
  class PayloadLengthError < StandardError ; end
  class PacketLengthError  < StandardError ; end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

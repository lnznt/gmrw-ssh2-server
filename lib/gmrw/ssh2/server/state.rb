# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/module'
require 'gmrw/utils/loggable'
require 'gmrw/alternative/active_support'
require 'gmrw/ssh2/message/catalog'
require 'gmrw/ssh2/server/constants'

class GMRW::SSH2::Server::State < Hash
  include GMRW::Utils::Loggable

  property_ro :message_catalog, 'GMRW::SSH2::Message::Catalog.new'

  delegate :logger, :reader, :to => :@service

  def initialize(service)
    @service = service

    reader.add_observer(:recv_message, method(:message_received))
  end

  def message_received(message)
    # TODO : 実装
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

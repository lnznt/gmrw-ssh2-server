# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'openssl'
require 'gmrw/utils/alias_resolver'

class OpenSSL::Cipher
  extend GMRW::Utils::AliasResolver

  class << self
    def new(name, *a)
        super(resolve_alias(name), *a)
    end
  end

  add_alias :ssh_name, 'aes128-cbc' => 'aes-128-cbc' 
end

p OpenSSL::Cipher.new('aes-128-cbc').name
p OpenSSL::Cipher.new(:ssh_name => 'aes128-cbc').name


# vim:set ts=2 sw=2 et fenc=utf-8:

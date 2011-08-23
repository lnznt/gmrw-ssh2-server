# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'

#
#= example
#
#   class C
#     extend Utils::AliasResolver
#
#     class << self
#        def new(name, *a)
#           super(resolve_alias(name), *a)
#        end
#     end
#
#
module GMRW; module Utils; module AliasResolver
  property_ro :aliases, 'Hash.new {|h,k| h[k] = {}}'

  def resolve_alias(hash)
    return hash unless hash.kind_of?(Hash)

    category, alias_name = hash.first
    aliases[category][alias_name] || alias_name
  end

  def add_alias(category, hash)
    aliases[category].merge!(hash)
  end

  def delete_alias(category, alias_name)
    aliases[category].delete(alias_name)
  end

  def delete_alias_category(category)
    aliases.delete(category)
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

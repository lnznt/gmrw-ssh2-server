#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

require 'gmrw/extension/extension'

module GMRW::Extension
  mixin Array do
    def to_hash
      Hash[ *flatten(1) ]
    end

    def mapping(*keys)
      keys.empty? ? mapping_by_index : mapping_by_name(*keys)
    end

    def mapping_by_name(*names)
      names.zip(self).to_hash
    end

    def mapping_by_index
      (0...count).zip(self).to_hash
    end
  end
end

if __FILE__ == $0
  p ["Taro",20].mapping(:name, :age, :address)
  p ["Taro",20].mapping(:name, :age)
  p ["Taro",20].mapping(:name)
  p ["Taro",20].mapping
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

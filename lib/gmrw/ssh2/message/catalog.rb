# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/utils/cascadable'
require 'gmrw/alternative/active_support'
require 'gmrw/ssh2/message'

class GMRW::SSH2::Message::Catalog
  include GMRW::Utils::Loggable
  include GMRW::Utils::Cascadable

  alias initialize cascade

  property_ro :category,   '[nil  ] * 256'
  property_ro :permission, '[false] * 256'

  def change_algorithm(hash)
    hash.each do |cate, algo|
      range = {:kex => 30..49, :auth => 60..79}[cate]
      category.fill(algo, range)

      debug( "message mode (#{range}) => #{algo}" )
    end
  end

  def permit(*nums)
    (nums.presence || [0..255]).each do |num|
      num = GMRW::SSH2::Message.classes[tag=num].try(:number) || num

      permission[num] = num.respond_to?(:count) ? [yield] * num.count : yield

      debug( "message permit (#{num}) => #{yield}" )
    end
  end

  def permit?(number)
    permission[number].tap do |pm|
      pm or error("permission denide: message ##{number}")
    end
  end

  def search(number)
    permit?(number) && search_tag(number)
  end

  def search_tag(number)
   debug( "search tag: #{number}" )
   GMRW::SSH2::Message.classes.select {|tag, mclass|
      mclass.number == number &&
      mclass.category.include?(category[number])
    }.map {|tag,| tag }[0]
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

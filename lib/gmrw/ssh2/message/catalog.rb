# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'
require 'gmrw/ssh2/message'

class GMRW::SSH2::Message::Catalog
  include GMRW
  include Utils::Loggable

  alias initialize logger=

  def transport_message?(number)  ; ( 1.. 49).include?(number) ; end
  def userauth_message?(number)   ; (50.. 79).include?(number) ; end
  def connection_message?(number) ; (80..127).include?(number) ; end

  property_ro :category,   '[nil  ] * 256'
  property_ro :permission, '[false] * 256'

  def change_kex_algorithm(algo)
    category.fill(algo, 30..49)
    debug( "message mode (kex) => #{algo}" )
  end

  def change_auth_algorithm(algo)
    category.fill(algo, 60..79)
    debug( "message mode (auth) => #{algo}" )
  end

  #def change_algorithm(hash)
  #  hash.each_pair do |cate, algo|
  #    category.fill(algo, {:kex => 30..49, :auth => 60..79}[cate] || cate)
  #    debug( "message mode (#{cate}) => #{algo}" )
  #  end
  #end

  def permit(*nums)
    (nums.presence || [0..255]).each do |num|
      num = SSH2::Message.classes[tag=num].try(:number) || num

      permission[num] = num.respond_to?(:count) ? [yield] * num.count : yield

      debug( "message permit (#{num}) => #{yield}" )
    end
  end

  def search(number)
    permit?(number) && search_tag(number)
  end

  private
  def permit?(number)
    permission[number] or raise SSH2::Message::ForbiddenMessage, number.to_s
  end

  def search_tag(number)
    debug( "search tag: #{number}" )
    SSH2::Message.classes.select {|tag, mclass|
      mclass.number == number && mclass.category.include?(category[number])
    }.map {|tag,| tag }[0] or raise SSH2::Message::MessageNotFound, number.to_s
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

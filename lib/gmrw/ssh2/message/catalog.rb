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

  property_ro :category, '[nil] * 256'

  def change_algorithm(algos)
    algos.each_pair do |cate, algo|
      (range = {:kex => 30..49, :auth => 60..79}[cate]) and
               category.fill(algo, range)               and
               debug( "message mode (#{cate}) => #{algo}" )
    end
  end

  def search(number)
    debug( "search tag: #{number}" )
    SSH2::Message.classes.select {|tag, mclass|
      mclass.number == number && mclass.category.include?(category[number])
    }.map {|tag,| tag }[0] or raise SSH2::Message::MessageNotFound, number.to_s
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

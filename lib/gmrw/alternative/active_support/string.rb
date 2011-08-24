# -*- coding: UTF-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

class String  #:nodoc:
  def at(pos)
    self[pos, 1]
  end

=begin
  def blank?
    !!match(/\A\s*\Z/)
  end

  def camelize(first_letter_in_uppercase = true)
    first_letter_in_uppercase ? upper_camelize : lower_camelize
  end

  private
  def upper_camelize
    lower_camelize.sub(/./) { $&.upcase }
  end

  def lower_camelize
    path_to_namespace.gsub(/(?:_|(::))(.)/) { "#{$1}#{$2.upcase}" }
  end

  def path_to_namespace
    gsub(/\//, '::')
  end
=end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

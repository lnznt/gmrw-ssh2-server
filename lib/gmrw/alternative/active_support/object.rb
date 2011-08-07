#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

class Object  #:nodoc:
  def blank?  #:nodoc:
    respond_to?(:empty?) ? empty? : !self
  end

  def present?  #:nodoc:
    !blank?
  end

  def try(*a, &b) #:nodoc:
    send(*a, &b)
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

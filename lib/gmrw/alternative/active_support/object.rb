#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

class Object  #:nodoc:
  def blank?
    respond_to?(:empty?) ? empty? : !self
  end

  def present?
    !blank?
  end

  alias try send
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

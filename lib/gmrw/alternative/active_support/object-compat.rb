#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

require 'gmrw/alternative/compatibility'

module GMRW::Alternative  #:nodoc:
  compatibility Object do
    def presence  #:nodoc:
      present? ? self : nil
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

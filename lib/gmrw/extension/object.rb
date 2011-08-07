#!/usr/bin/env ruby
# -*- coding :UTF-8 -*-

require 'gmrw/extension/extension'

module GMRW::Extension
  mixin Object do
    private
    def null
      @null ||= Class.new{ def method_missing(*) ; end }.new
    end
  end
end

if __FILE__ == $0
  class C
    def a
      null << "like a 'null' device"
    end
  end
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

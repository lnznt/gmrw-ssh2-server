#!/usr/bin/env ruby
# -*- coding: UTF-8 -*-

require 'gmrw/extension/extension'
require 'gmrw/extension/array'

module GMRW::Extension
  mixin String do
    def remove(s)
      sub(s, '')
    end

    alias - remove

    def indent(n, s=' ')
      (s * n) + self    
    end

    alias >> indent

    def wrap(w)
      (w[0,1] || '') + self + (w[-1,1] || '')
    end

    alias ** wrap

    def q
      wrap("'")
    end

    def qq
      wrap('"')
    end

    def parse(pattern)
      (match(pattern) || [])[1..-1]
    end

    def mapping(*names)
      (parse(yield) || []).mapping(*names)
    end
  end
end

if __FILE__ == $0
  p "abc".q
  p "SSH-2.0-Ruby/SSHServer".mapping(:ssh_ver, :prog_name) {/\A(SSH-.+?)-(.+)/}
  p "SSH-2.0-Ruby/SSHServer".mapping(:ssh_ver, :prog_name) {/\ASSH-.+?-.+/}
  p "SSH-2.0-Ruby/SSHServer".mapping(:ssh_ver, :prog_name) {/\A(FTP-.+?)-(.+)/}
end

# vim:set ts=2 sw=2 et fenc=UTF-8:

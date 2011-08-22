# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'zlib'

module GMRW; module SSH2; module Algorithm
  module Compressor
    include GMRW
    extend self

    def zlib_compressor
      zlib = Zlib::Deflate.new
      proc {|data| zlib.deflate(data, Zlib::SYNC_FLUSH) }
    end

    def zlib_decompressor
      zlib = Zlib::Inflate.new
      proc {|data| zlib.inflate(data) }
    end

    def get_compressor(mode, compressor_name)
      case compressor_name
        when 'zlib'
          mode == :compress ? zlib_compressor : zlib_decompressor
        when 'none'
          proc {|data| data }
        else
          raise "unknown compressor: #{compressor_name}"
      end
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

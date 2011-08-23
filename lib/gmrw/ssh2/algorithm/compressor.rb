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
      proc {|s| zlib.deflate(s, Zlib::SYNC_FLUSH) }
    end

    def zlib_decompressor
      zlib = Zlib::Inflate.new
      proc {|s| zlib.inflate(s) }
    end

    def get(comp_or_decomp, compressor_name)
      case compressor_name
        when 'zlib'
          { :compress   => zlib_compressor   ,
            :decompress => zlib_decompressor }[comp_or_decomp]

        when 'none'
          proc {|s| s }

      end or raise "unknown compressor: #{compressor_name}"
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

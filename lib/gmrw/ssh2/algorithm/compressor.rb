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

    def get(comp_or_decomp, name)
      compressor = {
        'zlib' => { :compress   => zlib_compressor    ,
                    :decompress => zlib_decompressor  },
        'none' => { :compress   => proc {|s| s }      ,
                    :decompress => proc {|s| s }      },
      }[name] or raise "unknown compressor: #{name}"

      compressor[comp_or_decomp]
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

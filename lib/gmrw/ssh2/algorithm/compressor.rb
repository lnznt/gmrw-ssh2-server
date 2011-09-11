# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'zlib'

module GMRW; module SSH2; module Algorithm
  class Compressor
    def_initialize :name

    property_ro :compress, '{
      "zlib" => zlib_compressor,
    }[name] || proc {|s| s }'

    property_ro :decompress, '{
      "zlib" => zlib_decompressor,
    }[name] || proc {|s| s }'

    private
    def zlib_compressor
      zlib = Zlib::Deflate.new
      proc {|s| zlib.deflate(s, Zlib::SYNC_FLUSH) }
    end

    def zlib_decompressor
      zlib = Zlib::Inflate.new
      proc {|s| zlib.inflate(s) }
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

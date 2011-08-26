# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/message/field'

module GMRW; module SSH2; module Message
  extend self
  property_ro :classes, '{}'

  def build(payload)
    number = payload.unpack("C")[0]
    tag    = yield.search(number)
    create(tag, payload)
  end

  def create(tag, data={})
    classes.fetch(tag).new(data)
  end

  def def_message(tag, fields, info={})
    options = fields.map {|_,fname,_,*a|
      [fname, {:requires  => a.grep(Hash )[0] || {},
               :choices   => a.grep(Array)[0],
               :converter => a.grep(Proc )[0] || proc {|v| v }} ]
    }.to_hash

    classes[tag] = Class.new(Hash) {
      define_method(:tag)       { tag           }
      private
      define_method(:fields)    { fields.freeze }
      define_method(:requires)  {|fname| options[fname][:requires ] }
      define_method(:converter) {|fname| options[fname][:converter] }
      define_method(:choices)   {|fname| options[fname][:choices]   }

      def avail_fields
        fields.select{|_,fname,| requires(fname).all?{|f,v| self[f] == v } }
      end

      def search_ftype(fname)
        avail_fields.rassoc(fname).try(:[], 0)
      end

      def convert(ftype, fname, val)
        converter(fname)[ val.nil? ? Field.default(ftype) : val ]
      end

      def verify(ftype, fname, val)
        (!(c = choices(fname)) || c.include?(val)) && Field.validate(ftype, val)
      end

      public
      def []=(fname, val) 
        ftype = search_ftype(fname) or return

        val = convert(ftype, fname, val)

        verify(ftype, fname, val) or raise TypeError, "#{fname}:#{val}"
        super
      end

      def initialize(data={})
        avail_fields.each {|ftype, fname, fval,|
          self[fname], data = data.respond_to?(:to_str) ? Field.decode(ftype, data):
                              !data[fname].nil?         ? [data[fname],     data]  :
                              fval.respond_to?(:call)   ? [fval.call(self), data]  :
                                                          [fval,            data]
        }
      end

      def dump
        avail_fields.map{|ftype, fname,| Field.encode(ftype, self[fname]) }.join
      end

    }.tap {|mclass|
      c = class << mclass ; self ; end
      c.send(:define_method, :number)   { fields[0][2]             }
      c.send(:define_method, :category) { info[:category] || [nil] }
    }

  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

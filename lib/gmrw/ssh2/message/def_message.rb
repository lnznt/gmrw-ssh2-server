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
               :converter => a.grep(Proc )[0] || proc {|v| v }} ]
    }.to_hash

    classes[tag] = Class.new(Hash) {
      define_method(:fields)    { fields.freeze }
      define_method(:requires)  {|fname| options[fname][:requires ] }
      define_method(:converter) {|fname| options[fname][:converter] }

      def avail?(fname)
        requires(fname).all? {|f,v| self[f] == v }
      end

      def []=(fname, val) 
        ftype = avail?(fname) && (fields.rassoc(fname) || [])[0] or return

        val = converter(fname)[ val.nil? ? Field.default(ftype) : val ]

        Field.validate(ftype, val) or raise TypeError, "#{fname}: #{val}"
        super
      end

      def initialize(data={})
        fields.each {|ftype, fname, fval,| next unless avail?(fname)
          self[fname], data = data.respond_to?(:to_str) ? Field.decode(ftype, data):
                              !data[fname].nil?         ? [data[fname],     data]  :
                              fval.respond_to?(:call)   ? [fval.call(self), data]  :
                                                          [fval,            data]
        }
      end

      def dump
        fields.map {|ftype, fname,|
          avail?(fname) ? Field.encode(ftype, self[fname]) : nil
        }.compact.join
      end

      def tag      ; self.class.tag      ; end
      def number   ; self.class.number   ; end
      def category ; self.class.category ; end

    }.tap do |mclass| (class << mclass ; self ; end).tap do |c|
      c.send(:define_method, :tag)      { tag                      }
      c.send(:define_method, :number)   { fields[0][2]             }
      c.send(:define_method, :category) { info[:category] || [nil] }
    end end

  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

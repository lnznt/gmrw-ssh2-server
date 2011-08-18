# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/alternative/active_support'
require 'gmrw/ssh2/message/fields'

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

  private
  def def_message(tag, fields, options={})
    classes[tag] = Class.new(Hash) {
      define_method(:tag)    { tag           }
      define_method(:fields) { fields.freeze }

      def []=(fname, val) 
        ftype = (fields.rassoc(fname) || [])[0]
        Fields.validate!(ftype, val) and super
      end

      def initialize(data={})
        fields.each do |ftype, fname, fval,|
          self[fname] = case data
            when String
              val, data = Fields.decode(ftype, data)
              val
            else
              !data[fname].nil?       ? data[fname]     :
              fval.respond_to?(:call) ? fval.call(self) :
              !fval.nil?              ? fval            :
                                        Fields.default(ftype)
          end
        end
      end

      def dump
        fields.map {|ftype, fname,| Fields.encode(ftype, self[fname]) }.join
      end
    }

    classes[tag].define_singleton_method(:number)   { fields[0][2]                }
    classes[tag].define_singleton_method(:category) { options[:category] || true  }
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

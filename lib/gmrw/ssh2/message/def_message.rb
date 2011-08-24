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
  rescue KeyError
    null
  end

  def def_message(tag, fields, info={})
    requires = fields.map{|_,fn,*a|   [fn, a.grep(Hash )[0]]}.to_hash
    choices  = fields.map{|_,fn,_,*a| [fn, a.grep(Array)[0]]}.to_hash

    classes[tag] = Class.new(Hash) {
      define_method(:tag)    { tag           }
      define_method(:fields) { fields.freeze }

      define_method(:appear?) do |fname|
        (requires[fname]||{}).all? {|f,v| self[f] == v }
      end

      define_method(:ok?) do |fname, val|
        !(cs = choices[fname]) || cs.include?(val)
      end

      def []=(fname, val) 
        return unless appear?(fname)

        ok?(fname, val) or raise ArgumentError, "#{fname}: #{val}"

        ftype = (fields.rassoc(fname) || [])[0]
        Field.validate(ftype, val) or raise TypeError, "#{fname}:#{val}"
        super
      end

      def initialize(data={})
        fields.each do |ftype, fname, fval,|
          next unless appear?(fname)

          self[fname] = case data
            when String
              val, data = Field.decode(ftype, data)
              val
            else
              !data[fname].nil?       ? data[fname]     :
              fval.respond_to?(:call) ? fval.call(self) :
              !fval.nil?              ? fval            :
                                        Field.default(ftype)
          end
        end
      end

      def dump
        fields.map {|ftype, fname,|
          Field.encode(ftype, self[fname]) if appear?(fname)
        }.compact.join
      end

    }.tap {|mclass|
      mclass.define_singleton_method(:number)   { fields[0][2]          }
      mclass.define_singleton_method(:category) { info[:category] || [nil] }
    }
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/message/datatype'

module GMRW; module SSH2; module Message
  extend self

  class MessageNotFound < RuntimeError ; end

  property_ro :classes, '{}'
  property_ro :catalog, 'Hash.new {|h,k| h[k] = {}}'

  #
  # :section: message build
  #
  def search(number)
    case number
      when 30.. 49 ; catalog[number][yield[:kex]]
      when 60.. 79 ; catalog[number][yield[:auth]]
      else         ; catalog[number][nil]
    end
  end

  def build(payload, &block)
    number = payload.unpack("C")[0]
    mclass = search(number, &block)
    mclass && mclass.new(payload) or raise MessageNotFound
  end

  #
  # :section: message create
  #
  def create(tag, data={})
    classes.fetch(tag).new(data)
  end

  #
  # :section: field
  #
  class Field
    def inspect
      avail? ? "#{name}:#{type} => #{value}" : "(#{name}:#{type})"
    end

    def avail?
      cond.all? {|f,v| message[f] == v }
    end

    def dump
      value.ssh.encode(type)
    end

    def value=(val)
      val = conv[ val.nil? ? default[] : val ]
      val.ssh.type?(type) or raise TypeError, "#{name}: #{val}"
      @value = val
    end

    property    :spec
    property_ro :type, 'spec[0]'
    property_ro :name, 'spec[1]'
    attr_reader :value

    private
    property_ro :default, %-
      proc do
        spec[2].nil?               ? ssh.default(type) :
        spec[2].respond_to?(:call) ? spec[2].call      : spec[2]
      end
    -
    property_ro :conv, 'proc {|v| (spec[3] || Hash.new(v))[v] }'
    property_ro :cond, 'spec[4] || {}'

    def_initialize :message
  end

  #
  # :section: message
  #
  def def_message(tag, fields, info={})
    classes[tag] = Class.new do
      define_method(:tag) { tag }

      property :seq

      def [](name)
        (field(name) || null).value
      end

      def dump
        s = "" ; each_field {|f| s << f.dump } ; s
      end

      private
      define_method(:fields) do
        @fields ||= fields.map {|f| Field.new(self).tap {|this| this.spec(f) } }
      end

      def field(name)
        fields.find {|f| f.name == name && f.avail? }
      end

      def each_field(&block)
        fields.each {|f| f.avail? && block[f] }
      end

      def initialize(s={})
        each_field do |f|
          f.value, s = s.is.string? ? s.ssh.decode(f.type) : [s[f.name], s]
        end
      end
    end 

    (info[:categories] || [nil]).each do |cate|
      catalog[number=fields[0][2]][cate] = classes[tag]
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

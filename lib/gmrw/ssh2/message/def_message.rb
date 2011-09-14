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

  property_ro :classes, '{}'
  property_ro :catalog, 'Hash.new {|h,k| h[k] = {}}'

  #
  # :section: message build
  #
  def search(number)
    is_kex      = proc {|n| (30..49).include?(n) }
    is_userauth = proc {|n| (60..79).include?(n) }

    is_kex     [number] ? catalog[number][yield[:kex     ]] :
    is_userauth[number] ? catalog[number][yield[:userauth]] :
                          catalog[number][true]
  end

  def build(payload, &block)
    number = payload.unpack("C")[0]
    mclass = search(number, &block)
    mclass && mclass.new(payload) or Object.new.send(:null)
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
      val = conv[ val.nil? ? default : val ]
      val.ssh.type?(type) or raise TypeError, "#{type}: #{name}: #{val}"
      @value = val
    end

    property    :spec
    property_ro :type, 'spec[0]'
    property_ro :name, 'spec[1]'
    attr_reader :value

    private
    property_ro :default, 'spec[2].nil? ? ssh.default(type) : spec[2]'
    property_ro :conv,    'proc {|v| x = (spec[3]||{})[v] ; x.nil? ? v : x }'
    property_ro :cond,    'spec[4] || {}'

    def_initialize :message
  end

  #
  # :section: message
  #
  def def_message(tag, fields, info={})
    classes[tag] = Class.new do
      define_method(:tag) { tag }

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

    mclass = classes[tag]
    number = fields[0][2]
    (info[:categories] || [true]).each {|c| catalog[number][c] = mclass }
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

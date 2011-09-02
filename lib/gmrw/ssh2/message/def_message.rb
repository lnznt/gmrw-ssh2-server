# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/field'

module GMRW; module SSH2; module Message
  include GMRW

  extend self
  property_ro :classes, '{}'
  property_ro :catalog, 'Hash.new {|h,k| h[k] = {}}'

  #
  # :section: catalog search
  #
  def create_catalog
    Struct.new(:kex, :auth).new
  end

  def search(number)
    cate = case number
      when 30..49 ; yield[:kex]
      when 60..79 ; yield[:auth]
    end
    catalog[number][cate]
  end

  #
  # :section: message build
  #
  def build(payload, &block)
    number = payload.unpack("C")[0]
    tag    = search(number, &block)
    create(tag, payload)
  end

  def create(tag, data={})
    classes.fetch(tag).new(data)
  end

  #
  # :section: field
  #
  class Field
    def inspect
      avail? ? "#{@name}:#{@type} => #{@value}" : "(#{@name}:#{@type})"
    end

    attr_reader :type, :name, :value

    def avail?
      @cond.all? {|f,v| @message[f] == v }
    end

    def dump
      @value.ssh.encode(@type)
    end

    def value=(val)
      val = @conv[ val.nil? ? default : val ]
      val.ssh.type?(@type) or raise TypeError, "#{@name}: #{val}"
      @value = val
    end

    private
    def default
      @default.nil?               ? SSH2::Field.default(@type) :
      @default.respond_to?(:call) ? @default[ @message ]       : @default
    end

    def initialize(spec)
      @type, @name, @default, *opts = *spec[:field]
      @cond                         = opts.grep(Hash)[0] || {}
      @conv                         = opts.grep(Proc)[0] || proc {|v| v }
      @message                      = spec[:message]
    end
  end

  #
  # :section: message
  #
  def def_message(tag, fields, info={})
    number = fields[0][2]
    (info[:category] || [nil]).each do |cate|
      catalog[number][cate] = tag
    end

    classes[tag] = Class.new do
      define_method(:tag) { tag }

      def [](name)
        (field(name) || null).value
      end

#      def []=(name, val)
#        (field(name) || null).value = val
#      end

      def dump
        s = "" ; each_field {|f| s << f.dump } ; s
      end

      private
      define_method(:fields) do
        @fields ||= fields.map {|f| Field.new(:field => f, :message => self) }
      end

      def field(name)
        (f = fields.find {|f| f.name == name }) && f.avail? && f
      end

      def each_field(&block)
        fields.each {|f| f.avail? && block[f] }
      end

      def initialize(data={})
        each_field do |f|
          f.value, data = data.is.string? ? data.ssh.decode(f.type) :
                                            [data[f.name], data]
        end
      end
    end 
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

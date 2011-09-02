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

  def build(payload)
    number = payload.unpack("C")[0]
    tag    = yield.search(number)
    create(tag, payload)
  end

  def create(tag, data={})
    classes.fetch(tag).new(data)
  end

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
      val.is.type?(@type) or raise TypeError, "#{@name}: #{val}"
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

  def def_message(tag, fields, info={})
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

    (class << classes[tag] ; self ; end).tap do |c|
      c.send(:define_method, :number)   { fields[0][2]             }
      c.send(:define_method, :category) { info[:category] || [nil] }
    end
  end
end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

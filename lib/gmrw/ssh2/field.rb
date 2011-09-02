# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#
require 'openssl'
require 'gmrw/extension/all'
require 'gmrw/ssh2/field/ssh_field'

module GMRW; module SSH2; module Field
  extend self
  def default(type)
    case type
      when :boolean  ; false
      when :byte     ; 0
      when :uint32   ; 0
      when :uint64   ; 0
      when :mpint    ; OpenSSL::BN.new(0.to_s)
      when :string   ; ""
      when :namelist ; []
      when Integer   ; type > 0 ? ([0] * type) : nil
    end
  end

  def field_size(type)
    case type
      when :boolean  ; 1
      when :byte     ; 1
      when :uint32   ; 4
      when :uint64   ; 8
      when :mpint    ; nil
      when :string   ; nil
      when :namelist ; nil
      when Integer   ; type
      else ; raise(TypeError, "#{type}")
    end 
  end

  def pack(*fields)
    fields.map {|ftype, val| val.ssh.encode(ftype) }.join
  end

  def unpack(s, ftypes)
    ftypes.reduce([[], s]) do |result, ftype|
      v, s = s.ssh.decode(ftype) ; [result[0] << v, s] 
    end
  end
end; end; end

module GMRW::Extension
  mixin Object do
    include GMRW
    property_ro :ssh, 'SSH2::Field::SSHField.new(self)'
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

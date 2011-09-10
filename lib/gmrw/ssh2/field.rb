# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#
require 'gmrw/extension/all'
require 'gmrw/ssh2/field/ssh_field'

=begin
module GMRW; module SSH2; module Field
  extend self
  def default(type)
    case n=type
      when :boolean  ; false
      when :byte     ; 0
      when :uint32   ; 0
      when :uint64   ; 0
      when :mpint    ; 0.to.bn
      when :string   ; ""
      when :namelist ; []
      when Integer   ; n > 0 ? ([0] * n) : nil
    end
  end
end; end; end
=end

module GMRW::Extension
  mixin Object do
    property_ro :ssh, 'GMRW::SSH2::Field::SSHField.new(self)'
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

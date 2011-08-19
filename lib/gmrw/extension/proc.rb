#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'

module GMRW::Extension
  Proc.extend Module.new do
    def convert(x)
      compat = x.respond_to?(:each_pair) ? cond(x)    :
               x.respond_to?(:each)      ? cat(x)     :
               x.respond_to?(:to_proc)   ? x.to_proc  : nil
   
      x = block_given? ? yield(x, compat) : compat

      x.respond_to?(:call) ? x : proc {|*| x }
    end

    def cat(procs, &block)
      procs.empty? ? n : procs.map{|pr| convert(pr, &block)}.reduce(&:+)
    end

    def cond(procs, &block)
      to_selector = proc {|x, c| c ? c : proc {|*a| x === a.first } }

      proc do |*a|
        procs.select{|s, | convert(s, &to_selector).call(*a) }.take(1).
              map   {|_,x| convert(x, &block      ).call(*a) }.first
      end
    end

    def t ; proc {|*| true  } ; end
    def f ; proc {|*| false } ; end
    def n ; proc {|*| nil   } ; end

    def otherwise ; t ; end

    def as_is
      proc {|*a| a.first }
    end
  end

  mixin Proc do
    def *(other)
      proc {|*a| call( Proc.convert(other).call(*a) )}
    end

    def +(other)
      proc {|*a| Proc.convert(other).call( call(*a) )}
    end

    def <<(*x)
      proc {|*a| call( *(x + a) )}
    end

    def >>(*x)
      proc {|*a| call( *(a + x) )}
    end

    def tee(pr)
      proc {|*a| call(*a).tap{|result| Proc.convert(pr).call(result) }}
    end
  end
end

# vi:set ts=2 sw=2 et fenc=utf-8:

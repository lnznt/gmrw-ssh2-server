#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/extension'

module GMRW::Extension
  Module.new do
    def convert(x)
      compat = x.respond_to?(:each_pair) ? cond(x)    :
               x.respond_to?(:each)      ? cat(x)     :
               x.respond_to?(:to_proc)   ? x.to_proc  : nil
   
      x = block_given? ? yield(x, compat) : compat

      x.respond_to?(:call) ? x : proc {|*| x }
    end

    alias [] convert

    def cat(procs, &block)
      procs.empty? ? n : procs.map{|pr| convert(pr, &block)}.reduce(&:rcompose)
    end

    def cond(procs, &block)
      to_selector = proc {|x, c| c ? c : proc {|*a| x === a.first } }

      proc do |*a|
        procs.select{|s, | convert(s, &to_selector)[*a] }.take(1).
              map   {|_,x| convert(x, &block      )[*a] }.first
      end
    end

    def t     ; proc {|*| true  } ; end
    def f     ; proc {|*| false } ; end
    def n     ; proc {|*| nil   } ; end
    def as_is ; proc {|a| a }     ; end

    def otherwise ; t ; end

    Proc.extend self
  end

  mixin Proc do
    def compose(other)    # f(x) * g(x) ==> f(g(x))
      proc {|*a| call( Proc[other][*a] ) }
    end

    def scompose(other)   # f(x) << g(x) ==> f(*g(x))
      proc {|*a| call( *Array(Proc[other][*a]) ) }
    end

    def rcompose(other)   # f(x) % g(x) ==> g(f(x))
      proc {|*a| Proc[other][call(*a)] }
    end

    def srcompose(other)  # f(x) >> g(x) ==> g(*f(x))
     proc {|*a| Proc[other][*Array(call(*a))] }
    end

    alias *  compose        # f(x) * g(x) ==> f(g(x))
    alias %  rcompose       # f(x) % g(x) ==> g(f(x))

    alias & scompose       # f(x) & g(x) ==> f(*g(x))
    alias | srcompose      # f(x) | g(x) ==> g(*f(x))

    def first_arg(*x)
      proc {|*a| call( *(x + a) )}
    end

    def last_arg(*x)
      proc {|*a| call( *(a + x) )}
    end

    alias << first_arg
    alias >> last_arg

    def tee(pr)
      proc {|*a| call(*a).tap{|result| Proc.convert(pr).call(result) }}
    end
  end
end

# vi:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/utils/command'

command = GMRW::Utils::Command.new

command.add {|s| puts "#1, #{s}" }
command.add {|s| puts "#2, #{s}" }
command.call("ruby")

puts "-" * 4

command.add {|s| puts "#3, #{s}" }
command.call("ruby")

puts "-" * 8 ##################################

command = GMRW::Utils::Command.new do |cmd|
  cmd.add {|s| puts "#1, #{s}" }
  cmd.add {|s| puts "#2, #{s}" }
end

command.call("ruby")

puts "-" * 4

command.add {|s| puts "#3, #{s}" }
command.call("ruby")

puts "-" * 8 ##################################

command_2 = command + proc {|s| puts "#4, #{s}" }
command_2.call("ruby")

puts "-" * 8 ##################################

command_3 = command_2 + [ proc {|s| puts "#5, #{s}" },
                          proc {|s| puts "#6, #{s}" } ]
command_3.call("ruby")

puts "-" * 8 ##################################

%w[ruby erlang haskell].each(&command)

puts "-" * 8 ##################################

command = GMRW::Utils::Command.new.add {|s| puts s }
command["bye"]

# vim:set ts=2 sw=2 et fenc=utf-8:

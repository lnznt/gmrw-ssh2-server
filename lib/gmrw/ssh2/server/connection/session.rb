# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/ssh2/loggable'
require 'gmrw/ssh2/server/connection/channel'
require 'gmrw/ssh2/server/connection/session/program'

class GMRW::SSH2::Server::Connection
  class Session
    include GMRW
    include Channel

    def_initialize :service
    property :program, 'Program.new(self)'
    property :term, '{}'
    property :env,  '{}'

    property_ro :requests, '{
      "env"     => :env_request_received,
      "pty-req" => :pty_req_request_received,
      "exec"    => :exec_request_received,
      "shell"   => :shell_request_received,
    }'

    def request(message)
      request = requests[message[:request_type]] || :not_support
      send(request, message) {|*a| message[:want_reply] && reply(*a) }
    end

    def not_support(*)
      yield( :channel_failure )
    end

    def env_request_received(message)
      env[message[:env_var_name]] = message[:env_var_value]
      yield( :channel_success )
    end

    def pty_req_request_received(message)
      env['TERM']   = message[:term_env_var]
      term[:cols]   = message[:term_cols]
      term[:rows]   = message[:term_rows]
      term[:width]  = message[:term_width]
      term[:height] = message[:term_height]
      term[:modes]  = message[:term_modes]
      yield( :channel_success )
    end

    def exec_request_received(message)
      program.start(message[:command])
      yield( :channel_success )
    end

    def shell_request_received(message)
      program.start
      yield( :channel_success )
    end
  end
end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'

module GMRW; module SSH2; module Server; class Connection
  class Session
    include GMRW
    include Utils::Loggable

    def_initialize :service
    forward [ :logger, :die, :send_message,
              :open_channel, :close_channel] => :service

    property    :open_message
    property_ro :end_point, 'Struct.new(:channel, :window_size, :maximum_packet_size)'
    property_ro :local, %-
      end_point.new(open_channel(self),
                    open_message[:initial_window_size],
                    open_message[:maximum_packet_size])
    -
    property_ro :peer, %-
      end_point.new(open_message[:sender_channel],
                    open_message[:initial_window_size],
                    open_message[:maximum_packet_size])
    -
    property_ro :index,   'local.channel'
    property_ro :closing, 'proc {}'

    property_ro :env, '{}'

    def reply(tag, params={})
      common_params = {
        :recipient_channel   => peer.channel,
        :sender_channel      => local.channel,
        :initial_window_size => local.window_size,
        :maximum_packet_size => local.maximum_packet_size,
      }
      send_message(tag, common_params.merge(params))
    end

    def channel_open_received(message)
      open_message(message)
      reply :channel_open_confirmation
    end

    property_ro :requests, %|
      Hash.new{ :not_support }.merge({
        "env"     => :env_request_received,
        "pty-req" => :pty_req_request_received,
        "shell"   => :shell_request_received,
      })
    |

    def not_support(message)
      yield( :channel_failure )
    end

    property    :term_modes, '{}'
    property_ro :shell_command, '"bash"'
    property_ro :shell, 'Struct.new(:to, :from, :err, :pid, :wait_th, :read_th, :err_th).new'

    def env_request_received(message)
      env[message[:env_var_name]] = message[:env_var_value]
      yield( :channel_success )
    end

    def pty_req_request_received(message)
      env['TERM'] = message[:term_env_var]
      parse_term_modes(message[:term_modes])
      yield( :channel_success )
    end

    def shell_request_received(message)
      from_parent, shell.to  = IO.pipe ; shell.to.sync  = true
      shell.from,  to_parent = IO.pipe ; to_parent.sync = true
      shell.err,   error_to  = IO.pipe ; error_to.sync  = true

      debug( "shell:env: #{env}" )
      shell.pid = Process.spawn(env, shell_command, :in => from_parent, :out => to_parent, :err => error_to)
      debug( "spawn: #{shell.pid}" )
      shell.wait_th = Process.detach(shell.pid)
      from_parent.close ; to_parent.close ; error_to.close

      shell.read_th = Thread.fork do
        debug( "shell.read_th: started" )
        begin
          loop do
            f, = IO.select([shell.from])[0]
            !f.eof? or raise EOFError

            s = f.gets
            debug( "shell.read_th:s.encoding: #{s.encoding}" )
            debug( "shell.read_th:s: #{s}" )
            reply :channel_data, :data => s.gsub("\n","\r\n")
          end
        rescue EOFError
          debug( "shell.read_th: EOF" )
          shell.err.close
          reply :channel_eof

          exit_status = shell.wait_th.value.exitstatus
          debug( "shell: exit_status: #{exit_status}" )
          reply :channel_request, :request_type => 'exit-status', 
                                  :exit_status => exit_status

          closing { shell.read_th.kill }
          sleep 1
          close_channel(self)
        rescue => e
          error( "shell.read_th: #{e}" )
          e.backtrace.each {|bt| debug( bt >> 2 ) }
        ensure
          debug( "shell.read_th: terminated" )
        end
      end

      shell.err_th = Thread.fork do
        debug( "shell.err_th: started" )
        begin
          loop do
            f, = IO.select([shell.err])[0]
            !f.eof? or raise EOFError

            s = f.gets
            debug( "shell.err_th:s.encoding: #{s.encoding}" )
            debug( "shell.err_th:s: #{s}" )

            reply :channel_extended_data,
                  :data_type => 1,  # SSH_EXTENDED_DATA_STDERR
                  :data      => s.gsub("\n", "\r\n")
          end
        rescue EOFError
          debug( "shell.err_th: EOF" )
        rescue => e
          error( "shell.err_th: #{e}" )
          e.backtrace.each {|bt| debug( bt >> 2 ) }
        ensure
          debug( "shell.err_th: terminated" )
        end
      end

      debug( "term_modes: #{term_modes}" )
      modes = parse_term_modes_as_stty_format.join(";")
      debug( "modes: #{modes}" )
      #shell.to.write modes + "\n"

      yield( :channel_success )
    end

    def channel_data_received(message, *)
      debug( "shell.wait_th: #{shell.wait_th} (#{shell.wait_th.status})" )
      debug( "shell.read_th: #{shell.read_th} (#{shell.read_th.status})" )
      debug( "shell.err_th:  #{shell.err_th}  (#{shell.err_th.status})" )

      shell.to.write message[:data].gsub("\r\n","\n").gsub("\r","\n")
    end

    def channel_request_received(message)
      request = requests[message[:request_type]]
      send(request, message) {|*a| message[:want_reply] && reply(*a) }
    end

    def parse_term_modes(modes)
      mode_codes = {
          0  => :TTY_OP_END,
          1  => :VINTR,
          2  => :VQUIT,
          3  => :VERASE,
          4  => :VKILL,
          5  => :VEOF,
          6  => :VEOL,
          7  => :VEOL2,
          8  => :VSTART,
          9  => :VSTOP,
          10 => :VSUSP,
          11 => :VDSUSP,
          12 => :VREPRINT,
          13 => :VWERASE,
          14 => :VLNEXT,
          15 => :VFLUSH,
          16 => :VSWTCH,
          17 => :VSTATUS,
          18 => :VDISCARD,

          30 => :IGNPAR,
          31 => :PARMRK,
          32 => :INPCK,
          33 => :ISTRIP,
          34 => :INLCR,
          35 => :IGNCR,
          36 => :ICRNL,
          37 => :IUCLC,
          38 => :IXON,
          39 => :IXANY,
          40 => :IXOFF,
          41 => :IMAXBEL,

          50 => :ISIG,
          51 => :ICANON,
          52 => :XCASE,
          53 => :ECHO,
          54 => :ECHOE,
          55 => :ECHOK,
          56 => :ECHONL,
          57 => :NOFLSH,
          58 => :TOSTOP,
          59 => :IEXTEN,
          60 => :ECHOCTL,
          61 => :ECHOKE,
          62 => :PENDIN,

          70 => :OPOST,
          71 => :OLCUC,
          72 => :ONLCR,
          73 => :OCRNL,
          74 => :ONOCR,
          75 => :ONLRET,

          90 => :CS7,
          91 => :CS8,
          92 => :PARENB,
          93 => :PARODD,

         128 => :TTY_OP_ISPEED,
         129 => :TTY_OP_OSPEED,
      }

      while (1..159).include?(modes.unpack("C")[0])
        c, n, modes = modes.unpack("CNa*")
        term_modes[mode_codes[c]] = n
      end

      debug( "#{term_modes}" )
    end

    def parse_term_modes_as_stty_format
      character = proc {|m,v| "stty #{m} 0x%02x" % v }
      number    = proc {|m,v| "stty #{m} %d" % v }
      flag      = proc {|m,v| "stty %s#{m}" % (v == 0 ? "-" : "") }
      is_or_not = proc {|m,v| v == 0 ? "" : "stty #{m}" }

      term_modes.map {|mode, val|
        {
          :VINTR      => character[ :intr,    val ],
#          :VQUIT      => character[ :quit,    val ],
#          :VERASE     => character[ :erase,   val ],
#          :VKILL      => character[ :kill,    val ],
#          :VEOF       => character[ :eof,     val ],
#          :VEOL       => character[ :eol,     val ],
#          :VEOL2      => character[ :eol2,    val ],
#          :VSTART     => character[ :start,   val ],
#          :VSTOP      => character[ :stop,    val ],
#          :VSUSP      => character[ :susp,    val ],
##          :VDSUSP     => character[ :dsusp,   val ],
#          :VREPRINT   => character[ :rprnt,   val ],
#          :VWERASE    => character[ :werase,  val ],
#          :VLNEXT     => character[ :lnext,   val ],
#          :VFLUSH     => character[ :flush,   val ],
#          :VSWTCH     => character[ :swtch,   val ],
##          :VSTATUS    => character[ :status,  val ],
##          :VDISCARD   => character[ :discard, val ],

#          :IGNPAR     => flag[ :ignpar,  val ],
#          :PARMRK     => flag[ :parmrk,  val ],
#          :INPCK      => flag[ :inpck,   val ],
#          :ISTRIP     => flag[ :istrip,  val ],
#          :INLCR      => flag[ :inlcr,   val ],
#          :IGNCR      => flag[ :igncr,   val ],
#          :ICRNL      => flag[ :icrnl,   val ],
#          :IUCLC      => flag[ :iuclc,   val ],
#          :IXON       => flag[ :ixon,    val ],
#          :IXANY      => flag[ :ixany,   val ],
#          :IXOFF      => flag[ :ixoff,   val ],
#          :IMAXBEL    => flag[ :imaxbel, val ],

#          :ISIG       => flag[ :isig,    val ],
#          :ICANON     => flag[ :icanon,  val ],
#          :XCASE      => flag[ :xcase,   val ],
#          :ECHO       => flag[ :echo,    val ],
#          :ECHOE      => flag[ :echoe,   val ],
#          :ECHOK      => flag[ :echok,   val ],
#          :ECHONL     => flag[ :echonl,  val ],
#          :NOFLSH     => flag[ :noflsh,  val ],
#          :TOSTOP     => flag[ :tostop,  val ],
#          :IEXTEN     => flag[ :iexten,  val ],
#          :ECHOCTL    => flag[ :echoctl, val ],
#          :ECHOKE     => flag[ :echoke,  val ],
##          :PENDIN     => flag[ :pendin,  val ],

#          :OPOST      => flag[ :opost,  val ],
#          :OLCUC      => flag[ :olcuc,  val ],
#          :ONLCR      => flag[ :onlcr,  val ],
#          :OCRNL      => flag[ :ocrnl,  val ],
#          :ONOCR      => flag[ :onocr,  val ],
#          :ONLRET     => flag[ :onlret, val ],

##          :CS7        => is_or_not[ :cs7, val ],
#          :CS8        => is_or_not[ :cs8, val ],
#          :PARENB     => flag[ :parenb, val ],
#          :PARODD     => flag[ :parodd, val ],

#          :TTY_OP_ISPEED => number[ :ispeed, val ],
#          :TTY_OP_OSPEED => number[ :ospeed, val ],
        }[mode]
      }.compact
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

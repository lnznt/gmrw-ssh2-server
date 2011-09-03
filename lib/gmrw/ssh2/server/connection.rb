# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'

module GMRW; module SSH2; module Server; class Connection
  include GMRW
  include Utils::Loggable

  def_initialize :service
  forward [:logger, :die, :send_message] => :service

  def start(service_name)
    debug( "in service: #{service_name}" )

    service.add_observer(:global_request,  &method(:global_request_received))
    service.add_observer(:channel_open,    &method(:channel_open_received))
    service.add_observer(:channel_request, &method(:channel_request_received))
    service.add_observer(:channel_data,    &method(:channel_data_received))
  end

  def global_request_received(message, *)
    message[:want_reply] && send_message(:request_failure)
  end

  ###########################################################################
  #
  # DUMMY
  #
  property :session, '{}'

  def channel_open_received(message, *a)
    case message[:channel_type]
      when 'session'
        session[:peer_channel ] = message[:sender_channel]
        session[:local_channel] = message[:sender_channel] + 10
        session[:initial_window_size] = message[:initial_window_size]
        session[:maximum_packet_size] = message[:maximum_packet_size]

        send_message :channel_open_confirmation,
                      :recipient_channel  => session[:peer_channel],
                      :sender_channel     => session[:local_channel],
                      :initial_window_size => session[:initial_window_size],
                      :maximum_packet_size => session[:maximum_packet_size]
      else
        send_message :channel_open_failure, :reason_code => :UNKNOWN_CHANNEL_TYPE,
                                            :description => :UNKNOWN_CHANNEL_TYPE,
                                            :recipient_channel => message[:sender_channel]
    end
  end

  def channel_request_received(message, *a)
    case message[:request_type]
      when 'env','shell'
        send_message :channel_success, :recipient_channel => session[:peer_channel]
      when 'pty-req'
        parse_term_modes message[:term_modes]
        send_message :channel_success, :recipient_channel => session[:peer_channel]
    end
  end

  def parse_term_modes(modes)
    commands = {
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

    parsed = []

    until modes.unpack("C")[0] == 0
      c, n, modes = modes.unpack("CNa*")
      parsed << [commands[c], n]
    end

    debug( "#{parsed}" )
  end

  def channel_data_received(message, *a)
    (session[:data] ||= "") << message[:data]

    if session[:data] =~ /([^\r]+)\r/
      cmd = $1
      debug( "cmd: #{cmd}" )
      result = `#{$1}` rescue ""
      session[:data] = ""

      send_message :channel_data, :recipient_channel => session[:peer_channel],
                                  :data => result
      send_message :channel_close, :recipient_channel => session[:peer_channel]
    end
  end
end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/extension/all'
require 'gmrw/utils/loggable'

module GMRW; module SSH2; module Server; class Connection; class Session
  module TerminalMode
    extend self
    def parse(modes)
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

      parsed = []
      while modes && !modes.empty?
        c, n, modes = modes.unpack("CNa*")
        parsed << [mode_codes[c], n]
      end
      parsed
    end

    def parse_for_stty(modes)
      modes.map {|mode, val|
        case mode 
          when :VINTR      ; "intr    0x%02x" % val
          when :VQUIT      ; "quit    0x%02x" % val
          when :VERASE     ; "erase   0x%02x" % val
          when :VKILL      ; "kill    0x%02x" % val
          when :VEOF       ; "eof     0x%02x" % val
          when :VEOL       ; "eol     0x%02x" % val
          when :VEOL2      ; "eol2    0x%02x" % val
          when :VSTART     ; "start   0x%02x" % val
          when :VSTOP      ; "stop    0x%02x" % val
          when :VSUSP      ; "susp    0x%02x" % val
          #when :VDSUSP     ; "dsusp   0x%02x" % val
          when :VREPRINT   ; "rprnt   0x%02x" % val
          when :VWERASE    ; "werase  0x%02x" % val
          when :VLNEXT     ; "lnext   0x%02x" % val
          when :VFLUSH     ; "flush   0x%02x" % val
          when :VSWTCH     ; "swtch   0x%02x" % val
          #when :VSTATUS    ; "status  0x%02x" % val
          #when :VDISCARD   ; "discard 0x%02x" % val

          when :IGNPAR     ; (val == 0 ? "-" : "") + "ignpar"
          when :PARMRK     ; (val == 0 ? "-" : "") + "parmrk"
          when :INPCK      ; (val == 0 ? "-" : "") + "inpck"
          when :ISTRIP     ; (val == 0 ? "-" : "") + "istrip"
          when :INLCR      ; (val == 0 ? "-" : "") + "inlcr"
          when :IGNCR      ; (val == 0 ? "-" : "") + "igncr"
          when :ICRNL      ; (val == 0 ? "-" : "") + "icrnl"
          when :IUCLC      ; (val == 0 ? "-" : "") + "iuclc"
          when :IXON       ; (val == 0 ? "-" : "") + "ixon"
          when :IXANY      ; (val == 0 ? "-" : "") + "ixany"
          when :IXOFF      ; (val == 0 ? "-" : "") + "ixoff"
          when :IMAXBEL    ; (val == 0 ? "-" : "") + "imaxbel"

          when :ISIG       ; (val == 0 ? "-" : "") + "isig"
          when :ICANON     ; (val == 0 ? "-" : "") + "icanon"
          when :XCASE      ; (val == 0 ? "-" : "") + "xcase"
          when :ECHO       ; (val == 0 ? "-" : "") + "echo"
          when :ECHOE      ; (val == 0 ? "-" : "") + "echoe"
          when :ECHOK      ; (val == 0 ? "-" : "") + "echok"
          when :ECHONL     ; (val == 0 ? "-" : "") + "echonl"
          when :NOFLSH     ; (val == 0 ? "-" : "") + "noflsh"
          when :TOSTOP     ; (val == 0 ? "-" : "") + "tostop"
          when :IEXTEN     ; (val == 0 ? "-" : "") + "iexten"
          when :ECHOCTL    ; (val == 0 ? "-" : "") + "echoctl"
          when :ECHOKE     ; (val == 0 ? "-" : "") + "echoke"
          #when :PENDIN     ; (val == 0 ? "-" : "") + "pendin"

          when :OPOST      ; (val == 0 ? "-" : "") + "opost"
          when :OLCUC      ; (val == 0 ? "-" : "") + "olcuc"
          when :ONLCR      ; (val == 0 ? "-" : "") + "onlcr"
          when :OCRNL      ; (val == 0 ? "-" : "") + "ocrnl"
          when :ONOCR      ; (val == 0 ? "-" : "") + "onocr"
          when :ONLRET     ; (val == 0 ? "-" : "") + "onlret"

          #when :CS7        ; val == 0 ? "" : "cs7"
          when :CS8        ; val == 0 ? "" : "cs8"
          when :PARENB     ; (val == 0 ? "-" : "") + "parenb"
          when :PARODD     ; (val == 0 ? "-" : "") + "parodd"

          when :TTY_OP_ISPEED ; "ispeed #{val}"
          when :TTY_OP_OSPEED ; "ospeed #{val}"
        end
      }.compact.map {|s| "stty #{s}" }
    end
  end
end; end; end; end; end

# vim:set ts=2 sw=2 et fenc=utf-8:

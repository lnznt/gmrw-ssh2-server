# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/utils/loggable'


logger = GMRW::Utils::Logger.new($stdout)

p logger.severity     # => :info
p logger.threshold    # => :info
                                            #               <sev>     <thr>
logger <<          "O: message #1 (---)"     # => output    (:info)  ==:info
logger.log(:debug, "N: message #2 (debug)")  # => no output (:debug) < :info
logger.debug(      "N: message #3 (debug)")  # => no output (:debug) < :info
logger.log(:error, "O: message #3 (error)")  # => output    (:error) >=:info
logger.error(      "O: message #4 (error)")  # => output    (:error) >=:info

p logger.threshold:debug    # => :debug
logger.debug("O: message #5 (debug)")        # => output (:debug)  >= :debug

p logger.threshold(:fatal)  # => :fatal
logger.error("N: message #6 (error)")        # => no output (:error) < :fatal

logger.fatal    # set severity to :fatal
logger << "O: message #7 (fatal)"            # => output (:fatal) >= :fatal

#
# with block
#
p logger.threshold(:info)  # => :info
logger.error("O: message #8 (error)") {|l,s,| l << l.format[s.upcase] }

#
# formatter
#
logger.format {|*msgs| msgs.map(&:upcase).join }
logger.error("<<<","O: message #9 (error)",">>>")

#
# loggable
#
class C
  include GMRW::Utils::Loggable
end

c = C.new
c.logger << "N: message #10"    # => no output (no logger)
c.error("N: message #11")       # => no output (no logger)

c.logger = logger
c.logger << "O: message #12"     # => output     :info  >=  :info
c.error("O: message #13")        # => output    (:errir) >= :info
c.debug("N: message #14")        # => no output (:debug) <  :info

c.error { p "Yes" }       # => do it    (:error) >= :info
c.debug { p "No"  }       # => don't it (:debug) <  :info


# vim:set ts=2 sw=2 et fenc=utf-8:

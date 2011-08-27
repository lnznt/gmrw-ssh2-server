# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

module GMRW; module SSH2; module Message
  class ForbiddenMessage < RuntimeError ; end
  class MessageNotFound  < RuntimeError ; end
end; end; end

require 'gmrw/ssh2/message/message/01_disconnect'
require 'gmrw/ssh2/message/message/02_ignore'
require 'gmrw/ssh2/message/message/03_unimplemented'
require 'gmrw/ssh2/message/message/04_debug'
require 'gmrw/ssh2/message/message/05_service_request'
require 'gmrw/ssh2/message/message/06_service_accept'

require 'gmrw/ssh2/message/message/20_kexinit'
require 'gmrw/ssh2/message/message/21_newkeys'

require 'gmrw/ssh2/message/message/dh_30_kexdh_init'
require 'gmrw/ssh2/message/message/dh_31_kexdh_reply'

require 'gmrw/ssh2/message/message/dh_gex_31_kex_dh_gex_group'
require 'gmrw/ssh2/message/message/dh_gex_32_kex_dh_gex_init'
require 'gmrw/ssh2/message/message/dh_gex_33_kex_dh_gex_reply'
require 'gmrw/ssh2/message/message/dh_gex_34_kex_dh_gex_request'

require 'gmrw/ssh2/message/message/50_userauth_request'
require 'gmrw/ssh2/message/message/51_userauth_failure'
require 'gmrw/ssh2/message/message/52_userauth_success'
require 'gmrw/ssh2/message/message/53_userauth_banner'

require 'gmrw/ssh2/message/message/password_60_userauth_passwd_changereq'
require 'gmrw/ssh2/message/message/publickey_60_userauth_pk_ok'

require 'gmrw/ssh2/message/message/90_channel_open'
require 'gmrw/ssh2/message/message/91_channel_open_confirmation'

# vim:set ts=2 sw=2 et fenc=utf-8:

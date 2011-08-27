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

require 'gmrw/ssh2/message/message/01_disconnect_message'
require 'gmrw/ssh2/message/message/02_ignore_message'
require 'gmrw/ssh2/message/message/03_unimplemented_message'
require 'gmrw/ssh2/message/message/04_debug_message'
require 'gmrw/ssh2/message/message/05_service_request_message'
require 'gmrw/ssh2/message/message/06_service_accept_message'

require 'gmrw/ssh2/message/message/20_kexinit_message'
require 'gmrw/ssh2/message/message/21_newkeys_message'

require 'gmrw/ssh2/message/message/dh_30_kexdh_init_message'
require 'gmrw/ssh2/message/message/dh_31_kexdh_reply_message'

require 'gmrw/ssh2/message/message/dh_gex_31_kex_dh_gex_group_message'
require 'gmrw/ssh2/message/message/dh_gex_32_kex_dh_gex_init_message'
require 'gmrw/ssh2/message/message/dh_gex_33_kex_dh_gex_reply_message'
require 'gmrw/ssh2/message/message/dh_gex_34_kex_dh_gex_request_message'

require 'gmrw/ssh2/message/message/50_userauth_request_message'
require 'gmrw/ssh2/message/message/51_userauth_failure_message'
require 'gmrw/ssh2/message/message/52_userauth_success_message'
require 'gmrw/ssh2/message/message/53_userauth_banner_message'

require 'gmrw/ssh2/message/message/password_60_userauth_passwd_changereq_message'
require 'gmrw/ssh2/message/message/publickey_60_userauth_pk_ok_message'

require 'gmrw/ssh2/message/message/90_channel_open_message'
require 'gmrw/ssh2/message/message/91_channel_open_confirmation_message'

# vim:set ts=2 sw=2 et fenc=utf-8:

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

require 'gmrw/ssh2/message/message/disconnect_message'
require 'gmrw/ssh2/message/message/ignore_message'
require 'gmrw/ssh2/message/message/unimplemented_message'
require 'gmrw/ssh2/message/message/debug_message'
require 'gmrw/ssh2/message/message/service_request_message'
require 'gmrw/ssh2/message/message/service_accept_message'

require 'gmrw/ssh2/message/message/kexinit_message'
require 'gmrw/ssh2/message/message/newkeys_message'

require 'gmrw/ssh2/message/message/kexdh_init_message'
require 'gmrw/ssh2/message/message/kexdh_reply_message'

require 'gmrw/ssh2/message/message/kex_dh_gex_request_message'
require 'gmrw/ssh2/message/message/kex_dh_gex_group_message'
require 'gmrw/ssh2/message/message/kex_dh_gex_init_message'
require 'gmrw/ssh2/message/message/kex_dh_gex_reply_message'

require 'gmrw/ssh2/message/message/userauth_request_message'
require 'gmrw/ssh2/message/message/userauth_failure_message'
require 'gmrw/ssh2/message/message/userauth_success_message'
require 'gmrw/ssh2/message/message/userauth_banner_message'
require 'gmrw/ssh2/message/message/userauth_pk_ok_message'
require 'gmrw/ssh2/message/message/userauth_passwd_changereq_message'

# vim:set ts=2 sw=2 et fenc=utf-8:

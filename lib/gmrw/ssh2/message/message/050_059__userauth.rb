# -*- coding: utf-8 -*-
#
# Author:: lnznt
# Copyright:: (C) 2011 lnznt.
# License:: Ruby's
#

require 'gmrw/ssh2/message/def_message'

module GMRW::SSH2::Message
  def_message :userauth_request, [
    [ :byte,    :type         ,50                                          ],
    [ :string,  :user_name                                                 ],
    [ :string,  :service_name                                              ],
    [ :string,  :method_name                                               ],

    [ :boolean, :with_pk_signature, nil, nil, { :method_name => 'publickey' }   ],
    [ :string,  :pk_algorithm,      nil, nil, { :method_name => 'publickey' }   ],
    [ :string,  :pk_key_blob,       nil, nil, { :method_name => 'publickey' }   ],
    [ :string,  :pk_signature,      nil, nil, { :method_name => 'publickey',
                                                :with_pk_signature => true  }   ],

    [ :boolean, :with_new_password, nil, nil, { :method_name => 'password'  }   ],
    [ :string,  :old_password,      nil, nil, { :method_name => 'password'  }   ],
    [ :string,  :new_password,      nil, nil, { :method_name => 'password',
                                                :with_new_password => true  }   ],

    [ :string,  :hb_algorithm,      nil, nil, { :method_name => 'hostbased' }   ],
    [ :string,  :hb_key_blob,       nil, nil, { :method_name => 'hostbased' }   ],
    [ :string,  :hb_hostname,       nil, nil, { :method_name => 'hostbased' }   ],
    [ :string,  :hb_username,       nil, nil, { :method_name => 'hostbased' }   ],
    [ :string,  :hb_signature,      nil, nil, { :method_name => 'hostbased' }   ],
  ]

  def_message :userauth_failure, [
    [ :byte,     :type               ,51 ],
    [ :namelist, :auths_can_continue     ],
    [ :boolean,  :partial_success        ],
  ]

  def_message :userauth_success, [
    [ :byte, :type, 52 ],
  ]

  def_message :userauth_banner, [
    [ :byte,   :type         ,53 ],
    [ :string, :message          ],
    [ :string, :language_tag     ],
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:

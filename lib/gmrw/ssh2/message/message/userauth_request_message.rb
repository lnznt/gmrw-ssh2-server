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
    [ :string,  :method_name, 'none', %w[publickey password hostbased none]],

    [ :boolean, :with_pk_signature,   { :method_name => 'publickey' }      ],
    [ :string,  :pk_algorithm,        { :method_name => 'publickey' }      ],
    [ :string,  :pk_key_blob,         { :method_name => 'publickey' }      ],
    [ :string,  :pk_signature,        { :method_name => 'publickey',
                                          :with_pk_signature => true  }    ],

    [ :boolean, :with_new_password,   { :method_name => 'password'  }      ],
    [ :string,  :old_password,        { :method_name => 'password'  }      ],
    [ :string,  :new_password,        { :method_name => 'password',
                                          :with_new_password => true  }    ],

    [ :string,  :hb_algorithm,        { :method_name => 'hostbased' }      ],
    [ :string,  :hb_key_blob,         { :method_name => 'hostbased' }      ],
    [ :string,  :hb_hostname,         { :method_name => 'hostbased' }      ],
    [ :string,  :hb_username,         { :method_name => 'hostbased' }      ],
    [ :string,  :hb_signature,        { :method_name => 'hostbased' }      ],
  ]
end

# vim:set ts=2 sw=2 et fenc=utf-8:

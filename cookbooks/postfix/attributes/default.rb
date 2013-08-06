#
# Author:: Joshua Timberman <joshua@opscode.com>
# Copyright:: Copyright (c) 2009, Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

default['postfix']['mail_type']  = "client"
default['postfix']['myhostname'] = node['fqdn']
default['postfix']['mydomain']   = node['domain']
default['postfix']['myorigin']   = "$myhostname"
default['postfix']['relayhost']  = "smtp.gmail.com:587"
default['postfix']['mail_relay_networks']        = "127.0.0.0/8"
default['postfix']['relayhost_role']             = "relayhost"
default['postfix']['multi_environment_relay'] = false
default['postfix']['inet_interfaces'] = nil

default['postfix']['smtpd_use_tls'] = "yes"
default['postfix']['smtp_use_tls']  = "yes"
default['postfix']['smtp_tls_security_level'] = "may"
default['postfix']['smtp_sasl_auth_enable'] = "yes"
default['postfix']['smtp_sasl_password_maps']    = "hash:/etc/postfix/sasl_passwd"
default['postfix']['smtp_sasl_security_options'] = "noanonymous"
default['postfix']['smtp_sasl_user_name'] = "linuxtrader@gmail.com"
default['postfix']['smtp_sasl_passwd']    = "stephen1"

default['postfix']['use_procmail'] = false

default['postfix']['milter_default_action']  = "tempfail"
default['postfix']['milter_protocol']  = "6"
default['postfix']['smtpd_milters']  = ""
default['postfix']['non_smtpd_milters']  = ""

default['postfix']['aliases'] = {
         :critical     => ['linuxtrader@gmail.com','dancell@mms.att.net'],
         :alert        => 'linuxtrader@gmail.com',
         :admin_local  => 'linuxtrader@gmail.com',
         :admin_global => 'linuxtrader@gmail.com',
         :root         => 'admin_global',
         :users        => ['linuxtrader@gmail.com','drmommarose@yahoo.com']
          }

default['postfix']['sender_canonical_classes'] = nil
default['postfix']['recipient_canonical_classes'] = nil
default['postfix']['canonical_classes'] = nil
default['postfix']['sender_canonical_maps'] = nil
default['postfix']['recipient_canonical_maps'] = nil
default['postfix']['canonical_maps'] = nil

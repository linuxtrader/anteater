#
# Cookbook Name:: ntp
# Recipe:: default
#
# Copyright 2012, linuxtrader, Com.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
package "ntp" do
    action [:install]
end
 
template "/etc/ntp.conf" do
    source "ntp.conf.erb"
    variables( 
      :ntp_server0 => "0.ubuntu.pool.ntp.org",
      :ntp_server1 => "1.ubuntu.pool.ntp.org",
      :ntp_server2 => "2.ubuntu.pool.ntp.org",
      :ntp_server3 => "3.ubuntu.pool.ntp.org",
      :ntp_serverfailback => "ntp.ubuntu.com" 
    )
    notifies :restart, "service[ntp]"
end
 
service "ntp" do
    action [:enable,:start]
end

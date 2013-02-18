#
# Cookbook Name:: befiles
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

####remote_directory "/usr/local/bin" do
####    source "local_bin"
####    owner "root"
####    group "root"
####    mode  "755"
####    files_mode "755"
# No purge because a package could place things here, plus basefiles does
#    if node[:hostname] =~ /^fe/
#      purge true
#    end
####end

remote_directory "/usr/local/etc" do
    source "local_etc"
    owner "root"
    group "root"
end

remote_directory "/usr/local/sbin" do
    source "local_sbin"
    files_owner "mythtv"
    files_group "mythtv"
    mode  "755"
    files_mode "755"
end

remote_directory "/etc" do
    source "etc"
    owner "root"
    group "root"
end


%w{hourly daily weekly monthly}.each do |cycle|
 remote_directory "/etc/cron.#{cycle}" do
    source "etc_cron_bin/cron.#{cycle}"
    files_mode "755"
 end
end


#####Cant purge in here cause lots of misc stuff collects that is needed
####remote_directory "/home/mythtv" do
####    source "home_mythtv"
####    files_owner "mythtv"
####    files_group "mythtv"
####end
####
#####Present from rule above, now enforce the mode
####%w{.bash_history .my.cnf .ssh/config}.each do |fil|
#### file "/home/mythtv/#{fil}" do
####  mode  "600"
#### end
####end
####
####directory "/home/mythtv/.ssh" do
####  mode  "700"
####end
####
####link "/home/mythtv/.profile" do
####  to ".bashrc"
####  owner "mythtv"
####  group "mythtv"
####end
####
####link "/home/mythtv/.mythtv/config.xml" do
####  to "/etc/mythtv/config.xml"
####  owner "mythtv"
####  group "mythtv"
####end
####
####link "/home/mythtv/.mythtv/mysql.txt" do
####  to "/etc/mythtv/mysql.txt"
####  owner "mythtv"
####  group "mythtv"
####end
####
####link "/home/ant/.mythtv/mysql.txt" do
####  to "/etc/mythtv/mysql.txt"
####  owner "ant"
####  group "ant"
####end

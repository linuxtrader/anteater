#
# Cookbook Name:: fefiles
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

bash "Relogin_Ant" do
    code <<-EOH
    /usr/bin/pkill -u ant
    /bin/sleep 3
    service gdm --full-restart
    EOH
    action: nothing
end
#notifies :run, "script[Relogin_Ant]"

remote_directory "/usr/local/bin" do
    source "local_bin"
    owner "root"
    group "root"
    mode  "755"
    files_mode "755"
# Actually a package could place things here, plus basefiles does
#    if node[:hostname] =~ /^fe/
#      purge true
#    end
end

remote_directory "/usr/local/etc" do
    source "local_etc"
    owner "root"
    group "root"
#   purge true
end

remote_directory "/usr/local/sbin" do
    source "local_sbin"
    files_owner "mythtv"
    files_group "mythtv"
    mode  "755"
    files_mode "755"
# Actually a package could place things here
#   if node[:hostname] =~ /^fe/
#     purge true
#   end
end

remote_directory "/etc" do
    source "etc"
    owner "root"
    group "root"
end

%w{quarterly weekly}.each do |cycle|
 remote_directory "/etc/cron.#{cycle}" do
    source "etc_cron_bin/cron.#{cycle}"
    files_mode "755"
 end
end

# ROBOTIC accts  ##########################

# MYTHTV and ANT
%w{mythtv ant}.each do |acct|

 remote_directory "/home/#{acct}" do
   source "home_#{acct}"
   #Probably the default but could be picked up
   #from a prior stanza
   files_mode "644"
   files_owner "#{acct}"
   files_group "#{acct}"
 end

 #enforce the mode, create file if missing
 file "/home/#{acct}/.bash_history" do
   mode  "600"
   owner "#{acct}"
   group "#{acct}"
 end

 directory "/home/#{acct}" do
   mode  "755"
 end

 directory "/home/#{acct}/.ssh" do
   mode  "700"
 end

 link "/home/#{acct}/.mythtv/mysql.txt" do
   to "/etc/mythtv/mysql.txt"
   owner "#{acct}"
   group "#{acct}"
 end

end

# MYTHTV ONLY
link "/home/mythtv/.profile" do
  to ".bashrc"
  owner "mythtv"
  group "mythtv"
end

link "/home/mythtv/.mythtv/config.xml" do
  to "/etc/mythtv/config.xml"
  owner "mythtv"
  group "mythtv"
end


# ANT ONLY
#And what of recordings for only BE/FE
%w{music pictures}.each do |mlink|
 link "/home/ant/Desktop/#{mlink}" do
   to "/var/lib/mythtv/#{mlink}"
   owner "ant"
   group "ant"
 end
end

#ant needs this too
remote_directory "/home/mythtv" do
    source "home_mythtv_secret"
    #This mode can actually carry over to 
    #another stanza that follows
    #esp of same destination
    files_mode "600"
    files_owner "mythtv"
    files_group "mythtv"
end

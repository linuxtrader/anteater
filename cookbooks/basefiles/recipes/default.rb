#
# Cookbook Name:: basefiles
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

remote_directory "/usr/local/bin" do
    source "local_bin"
    owner "root"
    group "root"
    mode  "755"
    files_mode "755"
end

remote_directory "/usr/local/etc" do
    source "local_etc"
    owner "root"
    group "root"
end

%w{weekly hourly}.each do |cycle|
 remote_directory "/etc/cron.#{cycle}" do
    source "etc_cron_bin/cron.#{cycle}"
    files_mode "755"
 end
end

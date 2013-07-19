#
# Cookbook Name:: basepkgs
# Recipe:: default
#
# Copyright 2013, linuxtrader, Com.
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

%w{avahi-daemon rdist tob system-config-lvm exaile nano}.each do |delpkg|
 package "#{delpkg}" do
   action  :purge
 end
end

%w{mime-construct smartmontools unison-gtk sysstat gparted fsarchiver nfs-common ethtool dstat git-core csh feh}.each do |addpkg|
 package "#{addpkg}" do
 end
end

#
# Copyright:: Copyright (c) 2011 Steven Danna <steve@opscode.com>
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Plugin to pull package list, versions, etc.
provides 'packages'

packages Mash.new

# platform detection should go here
# right now only centos/linux tested
cmd = "dpkg-query -W --showformat='${Package} = ${Version}\n'"

status, stdout, stderr = run_command(:command => cmd)
return "" if stdout.nil? || stdout.empty?
stdout.each do |line|
  k,v = line.split(/=/).map {|i| i.strip!}
  packages[k] = v
end

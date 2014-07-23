#
# Cookbook Name:: torquebox
# Recipe:: default
#
# Copyright 2014, Western University
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

default[:torquebox][:version] = '3.1.1'
default[:torquebox][:dist_file] = "torquebox-dist-#{node[:torquebox][:version]}-bin.zip"
default[:torquebox][:dist_url] = "http://torquebox.org/release/org/torquebox/torquebox-dist/#{node[:torquebox][:version]}/#{node[:torquebox][:dist_file]}"
default[:torquebox][:install_dir] = '/opt/torquebox'
default[:torquebox][:extracted_dir] = "torquebox-#{node[:torquebox][:version]}"
default[:torquebox][:current_version_link] = 'current'

# Platform-specific packages that are required for installation.
default[:torquebox][:packages] = value_for_platform(
  ["centos"] => {
   "default" => ["unzip"]
  }
)

default[:torquebox][:jboss][:user] = 'torquebox'
default[:torquebox][:jboss][:pid_file] = '/var/run/torquebox/torquebox.pid'
default[:torquebox][:jboss][:console_log] = '/var/log/torquebox/console.log'
default[:torquebox][:jboss][:config] = 'standalone.xml'

default[:torquebox][:home] = File.join(node[:torquebox][:install_dir], node[:torquebox][:current_version_link])
default[:torquebox][:jboss][:home] = File.join(node[:torquebox][:home], 'jboss')
default[:torquebox][:jruby][:home] = File.join(node[:torquebox][:home], 'jruby')
default[:torquebox][:jruby][:command] = File.join(node[:torquebox][:jruby][:home], 'bin', 'jruby')
default[:torquebox][:command] = File.join(node[:torquebox][:jruby][:home], 'bin', 'torquebox')


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

include_recipe "java"

current_version_dir = File.join(node[:torquebox][:install_dir], node[:torquebox][:current_version_link])

# Platform-specific packages that are required for installation.
node[:torquebox][:packages].each do |pkg|
  package pkg do
    action :install
  end
end

user node[:torquebox][:jboss][:user] do
  home     node[:torquebox][:install_dir]
  shell    "/bin/false"
  system   true
  comment  "torquebox system user"
  supports :manage_home=>true
  action   :create
end

directory node[:torquebox][:install_dir] do
  mode    '0755'
end

[
  node[:torquebox][:jboss][:pid_file],
  node[:torquebox][:jboss][:console_log]
].each do |file|

  directory File.dirname(file) do
    owner     node[:torquebox][:jboss][:user]
    recursive true
    mode      "0755"
  end

end

log 'switch torquebox version' do
  message "Installing torquebox version #{node[:torquebox][:version]}"
  only_if { ! (File.exist?(current_version_dir) && File.readlink(current_version_dir) =~ /torquebox-#{node[:torquebox][:version]}/) }

  notifies :create_if_missing, 'remote_file[torquebox package]', :immediately
  notifies :run, "bash[extract torquebox]", :immediately
  notifies :run, "bash[stop torquebox before upgrade]", :immediately
end

remote_file 'torquebox package' do
  source   node[:torquebox][:dist_url]
  path     File.join(node[:torquebox][:install_dir], node[:torquebox][:dist_file])
  action   :nothing
end

bash 'extract torquebox' do
  user   node[:torquebox][:jboss][:user]
  cwd    node[:torquebox][:install_dir]
  code   "unzip -o #{node[:torquebox][:dist_file]}"
  action :nothing
end

# We only want to stop the torquebox service if its init script is installed
# (i.e. this is an upgrade and not a new installation).  There does not appear
# to be an elegant way to this with notifications, the 'service' resource, and
# the only_if condition, so we resort to bash.
bash 'stop torquebox before upgrade' do
  user    "root"
  code    "/etc/init.d/torquebox stop"
  only_if { File.exists?("/etc/init.d/torquebox") }
  action  :nothing
end

link 'torquebox current directory' do
  target_file File.join(node[:torquebox][:install_dir], node[:torquebox][:current_version_link])
  to          File.join(node[:torquebox][:install_dir], node[:torquebox][:extracted_dir])
  notifies    :restart, "service[torquebox]", :delayed
end

link "/etc/init.d/torquebox" do
  to     File.join(node[:torquebox][:jboss][:home], "bin", "init.d", "jboss-as-standalone.sh")
  notifies :restart, "service[torquebox]", :delayed
end

directory "/etc/jboss-as" do
  owner "root"
  group "root"
  mode  "0755"
end

template "/etc/jboss-as/jboss-as.conf" do
  source   "jboss-as.conf.erb"
  owner    "root"
  group    "root"
  mode     "0644"
  notifies :restart, "service[torquebox]"
end

template "/etc/profile.d/torquebox.sh" do
  source  "torquebox.sh.erb"
  owner   "root"
  group   "root"
  mode    "0755"
end

service "torquebox" do
  supports :status => true, :restart => true, :reload => true
  action   :enable
end


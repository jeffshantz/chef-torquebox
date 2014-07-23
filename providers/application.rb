#
# Cookbook Name:: torquebox
# Provider:: application
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

# When use_inline_resources is added to the file, the code in the lightweight
# provider’s action block will execute as part of a self-contained chef-client
# run. If any embedded lightweight resources are updated, the top-level
# lightweight resource is marked as updated and notifications set for the
# top-level resource will be triggered normally.
use_inline_resources

action :deploy do
  unless @current_resource.exists

    cmd = ["PATH=#{::File.dirname(node[:torquebox][:jruby][:command])}:" + '$PATH', node[:torquebox][:command], 'deploy']
    cmd += ["--name", @new_resource.name]
    cmd += ["--env", @new_resource.env || 'production']
    cmd += ["--context-path", @new_resource.context_path] if @new_resource.context_path
    cmd << @new_resource.root

    cmd = cmd.join(" ")

    Chef::Log.debug(cmd)
    
    bash "deploy torquebox application" do

      user          node[:torquebox][:jboss][:user]
      cwd           node[:torquebox][:jboss][:home]
      environment({ 
                    'TORQUEBOX_HOME' => node[:torquebox][:home],
                    'JBOSS_HOME'     => node[:torquebox][:jboss][:home],
                    'JRUBY_HOME'     => node[:torquebox][:jruby][:home]
                  })
      code        cmd
    end

    Chef::Log.info("#{@new_resource} application deployed.")
  else
    Chef::Log.debug("#{@new_resource} application already exists - nothing to do")
  end
end

def load_current_resource
  @current_resource = Chef::Resource::TorqueboxApplication.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.root(@new_resource.root)
  @current_resource.env(@new_resource.env)
  @current_resource.context_path(@new_resource.context_path)

  @current_resource.exists = knob_exists?(@current_resource)

  @current_resource
end

private

def knob_exists?(test_knob)

  knob_yml = knob_file(test_knob.name)

  if ::File.exist?(knob_yml)
    knob = ::YAML::load_file(knob_yml)

    name = ::File.basename(knob_yml, '-knob.yml')
    root = knob["application"] && knob["application"]["root"] || nil
    env = knob["environment"] && knob["environment"]["RACK_ENV"] || nil
    context_path = knob["web"] && knob["web"]["context"] || nil

    # Verify that the knob being tested has the same attributes as the 
    # knob data loaded from disk, and that the last deployment did not fail.
    # Also check that one of the .yml.dodeploy, .yml.isdeploying, or .yml.deployed
    # files exist.  The first two files indicate that the application is still 
    # deploying -- perhaps from a previous run of the chef-client.  The .deployed
    # file indicates that the application is properly deployed.
    return test_knob.name == name &&
           test_knob.root == root &&
           test_knob.env  == env  &&
           test_knob.context_path == context_path &&
           ! ::File.exist?(failed_file(name)) &&
           (::File.exist?(dodeploy_file(name)) ||
            ::File.exist?(isdeploying_file(name)) ||
            ::File.exist?(deployed_file(name)))
  else
    false
  end

end



def knob_file(name)
  ::File.join(node[:torquebox][:jboss][:home], 'standalone', 'deployments', "#{name}-knob.yml")
end

# Unused
def deployed_file(name)
  knob_file(name) + '.deployed'
end

# Unused
def dodeploy_file(name)
  knob_file(name) + '.dodeploy'
end

def isdeploying_file(name)
  knob_file(name) + '.isdeploying'
end

def failed_file(name)
  knob_file(name) + '.failed'
end


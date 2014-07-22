# chef-torquebox

Chef cookbook to install / configure Torquebox on a node.

## Supported Platforms

* CentOS (tested on 6.5)

## Dependencies

This cookbook depends on the following cookbooks:

* `java`

## Attributes


<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>node[:torquebox][:version]</tt></td>
    <td>String</td>
    <td>Version of Torquebox to install (supports upgrading)</td>
    <td><tt>3.1.1</tt></td>
  </tr>
  <tr>
    <td><tt>node[:torquebox][:install_dir]</tt></td>
    <td>String</td>
    <td>Torquebox installation directory</td>
    <td><tt>/opt/torquebox</tt></td>
  </tr>
  <tr>
    <td><tt>node[:torquebox][:jboss][:user]</tt></td>
    <td>String</td>
    <td>User under which to run Torquebox (will be created if not present)</td>
    <td><tt>torquebox</tt></td>
  </tr>
  <tr>
    <td><tt>node[:torquebox][:jboss][:pid_file]</tt></td>
    <td>String</td>
    <td>Path to Torquebox PID file</td>
    <td><tt>/var/run/torquebox/torquebox.pid</tt></td>
  </tr>
  <tr>
    <td><tt>node[:torquebox][:jboss][:console_log]</tt></td>
    <td>String</td>
    <td>Path to the Torquebox log file</td>
    <td><tt>/var/log/torquebox/console.log</tt></td>
  </tr>
  <tr>
    <td><tt>node[:torquebox][:jboss][:config]</tt></td>
    <td>String</td>
    <td>
      <p>JBoss configuration file to use. This should be located in 
         <tt>#{node[:torquebox][:jboss][:home]}/standalone/configuration</tt>
         (see <tt>attributes/server.rb</tt>).
      </p>
    </td>
    <td><tt>standalone.xml</tt></td>
  </tr>
</table>

## Usage

### torquebox::server

Include `torquebox::server` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[torquebox::server]"
  ]
}
```

If you wish to use a different version of Torquebox from the default, or you
wish to change the version of Torquebox already installed by this recipe,
change the value of `version` accordingly:

```json
{
  "default_attributes": {
    "torquebox": {
      "version": "3.0.0"
    }
  }
}
```

Note that while switching versions appears to work in my tests, you will need
to redeploy all applications to the new version using the `torquebox_application`
resource.

## Resources/Providers

### torquebox_application

Deploys a Torquebox application.

#### Actions

* `:deploy`: deploy the application

#### Attributes

<table>
  <thead>
    <tr>
      <th>Attribute</th>
      <th>Description</th>
      <th>Example</th>
      <th>Default</th>
    </tr>
  </thead>

  <tbody>
    <tr>
      <td><tt>name</tt></td>
      <td>Name of the application being deployed.</td>
      <td><tt>razor-server</tt></td>
      <td>Current resource name</td>
    </tr>
    <tr>
      <td><tt>env</tt></td>
      <td>Torquebox environment under which the application should be deployed.</td>
      <td><tt>production</tt>, <tt>development</tt>, <tt>test</tt>, ...</td>
      <td><tt>production</tt></td>
    </tr>
    <tr>
      <td><tt>root</tt> <strong>(required)</strong></td>
      <td>
        <p>
          A directory containing the application to be deployed, a
          <tt>-knob.yml</tt> file, a <tt>.knob</tt> archive, or any Java
          deployable artifact (<tt>.war</tt>, <tt>.ear</tt>, etc).
        </p>
      </td>
      <td><tt>/opt/razor-server</tt></td>
      <td>None</td>
    </tr>
    <tr>
      <td><tt>context_path</tt></td>
      <td>The web context path for the application.</td>
      <td><tt>/myapp</tt></td>
      <td><tt>nil</tt></td>
    </tr>
  </tbody>
</table>

#### Example

```ruby
torquebox_application 'razor-server' do
  env  'production'
  root '/opt/razor-server'
end
```

## Testing

TODO!

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (i.e. `add-new-recipe`)
3. Write you change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request

## License and Authors

Author:: Jeff Shantz (<jeff@csd.uwo.ca>)

```text
Copyright:: 2014, Western University

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

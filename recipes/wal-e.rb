#
# Cookbook Name:: postgresql
# Recipe:: wal-e
#
# Author:: Kris Wehner (kris@seatme.com)
# Copyright 2013, SeatMe Inc.
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

include_recipe "postgresql::client"
package "daemontools" do
    action :install
end

# For the time being, this only supports ubuntu using a one-off ppa
# that contains a packaged version of wal-e

apt_repository "heroku-postgres" do
    uri "deb http://ppa.launchpad.net/drfarina/heroku-precise/ubuntu"
    distribution node['lsb']['codename']
    components ["main"]
end

package "python-wal-e" do
    action :install
end

directory "/etc/env.d/wal-e" do
    action :create
    recursive true
    user "root"
    group "postgres"
    mode "0750"
end

secret = Chef::EncryptedDataBagItem.load_secret("/etc/chef/encrypted_data_bag_secret")
aws = Chef::EncryptedDataBagItem.load("aws",node.chef_environment,secret)

file "/etc/env.d/wal-e/AWS_ACCESS_KEY_ID" do
    content aws['aws_access_key_id']
    action :create
end

file "/etc/env.d/wal-e/AWS_SECRET_ACCESS_KEY" do
    content aws['aws_secret_access_key']
    action :create
end


file "/etc/env.d/wal-e/WALE_S3_PREFIX" do
    content node['postgresql']['wal-e']['s3-prefix']
    action :create
end

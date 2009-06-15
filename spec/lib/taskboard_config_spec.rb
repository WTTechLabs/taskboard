# Copyright (C) 2009 Cognifide
# 
# This file is part of Taskboard.
# 
# Taskboard is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Taskboard is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Taskboard. If not, see <http://www.gnu.org/licenses/>.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'yaml'
require 'taskboard_config'

describe TaskboardConfig do

  it "should parse yml file" do
    conf = TaskboardConfig.new
    conf.jira_auth_data = {"some.url.com" => { "os_password" => "pass", "os_username" => "user" } }

    YAML.should_receive(:load_file).and_return(conf)

    TaskboardConfig.reset
    TaskboardConfig.instance.jira_auth_data["some.url.com"]["os_password"].should eql("pass")
    TaskboardConfig.instance.jira_auth_data["some.url.com"]["os_username"].should eql("user")
  end

  it "should log errors" do
    YAML.should_receive(:load_file).and_raise(Errno::ENOENT)

    TaskboardConfig.reset
    TaskboardConfig.instance.jira_auth_data.nil?.should be_true
  end

end


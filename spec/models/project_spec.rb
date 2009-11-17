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

describe Project do
  fixtures :projects, :taskboards

  it "should create a new instance with given name" do
    Project.create!(:name => "Test Project")
  end

  it "should not be valid with empty name" do
    [nil, "", " ", "    " ].each { |invalid_name|
        project = Project.new(:name => invalid_name)
        project.should_not be_valid 
    }
  end

  it "should have correct number of taskboards assigned" do
    project = projects(:sample_project)
    project.should have_at_least(1).taskboard
  end

  it "should define default project's name" do
    Project::DEFAULT_NAME.should_not be_empty
  end

end

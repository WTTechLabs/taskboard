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

describe ProjectController, "while showing projects list page" do

  integrate_views

  before(:each) do
    @projects = [Project.new(:name => "Dummy test project")]
  end

  it "should map index page to 'home' url" do
    route_for(:controller => "project", :action => "index").should == "/home"
  end

  it "should show list of projects for editor" do
    Project.should_receive(:find).with(:all, :order => "name").and_return(@projects)
    get_as_editor 'index'
    response.should be_success
    response.should have_tag("form[action=?]", "/taskboard/add_taskboard")
    response.should have_tag("form[action=?]", "/project/add")
  end

  it "should show list of taskboards for viewer" do
    Project.should_receive(:find).with(:all, :order => "name").and_return(@projects)
    get_as_viewer 'index'
    response.should be_success
    response.should_not have_tag("form[action=?]", "/taskboard/add_taskboard")
    response.should_not have_tag("form[action=?]", "/project/add")
  end

end

describe ProjectController, "while adding a project" do

  it "should allow adding new taskboards" do
    project = Project.new
    Project.should_receive(:new).and_return(project)
    project.should_receive(:save!)
    post_as_editor 'add', :name => 'Testing new project!'
    response.should redirect_to :action => 'index'
    project.name.should eql 'Testing new project!'
    project.should have(0).taskboards
  end

  it "should add project with default name if name not given" do
    project = Project.new
    Project.should_receive(:new).and_return(project)
    post_as_editor 'add'
    project.name.should eql Project::DEFAULT_NAME
  end

end

describe ProjectController, "while renaming project" do

  it "should allow changing name of a project" do
    project = Project.new(:name => "old name")
    Project.should_receive(:find).with(3).and_return(project)
    project.should_receive(:save!)
    post_as_editor 'rename', :id => 3, :name => 'new name'
    response.should be_success
    response.body.decode_json["status"].should eql 'success'
    project.name.should eql 'new name'
  end

  it "should not allow blank project name" do
    project = Project.new(:name => "old name")
    Project.should_receive(:find).with(3).and_return(project)
    project.should_not_receive(:save!)
    post_as_editor 'rename', :id => 3, :name => '    '
    response.should be_success
    response.body.decode_json["status"].should eql 'error'
    project.name.should eql 'old name'
  end

end


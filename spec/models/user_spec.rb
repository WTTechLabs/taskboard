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

describe User do
  fixtures :users
  
  it "should save hashed password when password is set" do
    user = User.new(:username => "testuser", :password => "testpassword")
    user.hashed_password.should_not be_empty
    user.hashed_password.should_not eql("testpassword")
    user.password.should eql("testpassword")
    
    user.valid?.should eql(true)
  end

  it "should not allow to save user without password" do
    user = User.new(:username => "testuser")
    user.valid?.should eql(false)
  end
  
  it "should not allow creating second user with same username" do
    user1 = User.new(:username => "name", :password => "testpassword")
    user1.save
    user2 = User.new(:username => "name", :password => "testpassword")
    user2.valid?.should eql(false)
  end
  
  it "should create some salt" do
    salt1 = User.new(:username => "name", :password => "password").salt
    salt1.should_not be_empty
    salt2 = User.new(:username => "name", :password => "password").salt
    salt2.should_not be_empty
    salt2.should_not eql(salt1)
  end
  
  
  it "should authenticate user if correct password is given" do
    user = users(:editor)
    authenticated_user = User.authenticate(user.username, "editor_password")
    authenticated_user.should_not be_nil
    authenticated_user.should eql(user)
  end

  it "should authenticate user if wrong password is given" do
    user = users(:editor)
    authenticated_user = User.authenticate(user.username, "wrongpassword")
    authenticated_user.should be_nil
  end
  
  it "should authenticate user if wrong username is given" do
    authenticated_user = User.authenticate("fakeuser", "password")
    authenticated_user.should be_nil
  end
end


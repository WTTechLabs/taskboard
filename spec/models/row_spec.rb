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

describe Row do
  fixtures :taskboards
  
  before(:each) do
    @valid_attributes = {
      :name => 'TODO',
      :position => 1,
      :taskboard_id => taskboards(:first_iteration).id
    }
  end

  it "should create a new instance given valid attributes" do
    Row.create!(@valid_attributes)
  end
end

describe Row, "while working with database" do
  fixtures :taskboards, :rows

  it "should have non-empty collection of rows" do
    Row.find(:all).should_not be_empty
  end
  

  it "should allow inserting new row at given position" do
    row = Row.create!(:name => 'new row', :taskboard_id => taskboards(:first_iteration).id)
    row.insert_at(2)
    row.higher_item.should eql(rows(:first_row))
    row.lower_item.should eql(rows(:second_row))
  end

  it "should define default name" do
    Row.default_name.should_not be_empty
  end
end

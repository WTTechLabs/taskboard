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
      :taskboard_id => taskboards(:scrum_taskboard).id
    }
  end

  it "should create a new instance given valid attributes" do
    Row.create!(@valid_attributes)
  end
end

describe Row, "while working with database" do
  fixtures :taskboards, :columns, :rows, :cards

  it "should have non-empty collection of rows" do
    Row.find(:all).should_not be_empty
  end
  
  it "should allow inserting new row at given position" do
    @taskboard = taskboards(:scrum_taskboard)
    @row_1 = rows(:scrum_user_row)
    @row_2 = rows(:scrum_owner_row)
    row = Row.create!(:name => 'new row', :taskboard => @taskboard)
    row.insert_at(2)
    row.higher_item.should eql(@row_1)
    row.lower_item.should eql(@row_2)
  end

  it "should define default name" do
    Row::DEFAULT_NAME.should_not be_empty
  end

  it "should contain valid number of cards" do 
    row = rows(:demo_first_row)
    row.should have_at_least(1).card
  end

  it "should get cards in given row" do
    column = columns(:scrum_todo_column)
    row = rows(:scrum_owner_row)
    row.cards.in_column(column).length.should < row.cards.length
  end

  it "should clone name and position" do
    row = rows(:demo_first_row)
    clonned = row.clone

    clonned.class.should be(Row)
    clonned.should_not eql(row)
    clonned.name.should eql(row.name)
    clonned.position.should eql(row.position)
    clonned.taskboard_id.should eql(row.taskboard_id)

    clonned = row.clone 234

    clonned.class.should be(Row)
    clonned.should_not eql(row)
    clonned.name.should eql(row.name)
    clonned.position.should eql(row.position)
    clonned.taskboard_id.should eql(234)
  end
  
end

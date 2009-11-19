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

describe Column do
  fixtures :taskboards

  before(:each) do
    @valid_attributes = {
      :name => 'TODO',
      :position => 1,
      :taskboard => taskboards(:scrum_taskboard)
    }
  end

  it "should create a new instance given valid attributes" do
    Column.create!(@valid_attributes)
  end
end

describe Column, "while working with database" do
  fixtures :taskboards, :columns, :rows, :cards

  it "should have non-empty collection of columns" do
    Column.find(:all).should_not be_empty
  end

  it "should contain valid number of cards" do 
    column = columns(:scrum_todo_column)
    column.should have_at_least(1).card
  end

  it "should get cards in given row" do
    column = columns(:scrum_todo_column)
    row = rows(:scrum_owner_row)
    column.cards.in_row(row).length.should < column.cards.length
  end

  it "should allow inserting new column at given position" do
    @taskboard = taskboards(:scrum_taskboard)
    @column_1 = columns(:scrum_story_column)
    @column_2 = columns(:scrum_todo_column)
    column = Column.create!(:name => 'very new column', :taskboard => @taskboard)
    column.insert_at(2)
    column.higher_item.should eql(@column_1)
    column.lower_item.should eql(@column_2)
  end

  it "should define default name" do
    Column::DEFAULT_NAME.should_not be_empty
  end

  it "should clone right poperties" do
    column = columns(:scrum_todo_column)
    clonned = column.clone

    clonned.class.should be(Column)
    clonned.should_not eql(column)
    clonned.name.should eql(column.name)
    clonned.position.should eql(column.position)
    clonned.taskboard_id.should eql(column.taskboard_id)

    clonned = column.clone 234

    clonned.class.should be(Column)
    clonned.should_not eql(column)
    clonned.name.should eql(column.name)
    clonned.position.should eql(column.position)
    clonned.taskboard_id.should eql(234)
  end
end

describe Column, "while serializing to json" do
  fixtures :columns, :cards

  before(:each) do
    @column = columns(:scrum_todo_column)
  end

  it "should not include any dates" do
    @column.to_json.should_not include('created_at')
    @column.to_json.should_not include('updated_at')
  end

  it "should not include any references to foreign keys" do
    @column.to_json.should_not include('taskboard_id')
  end

  it "should include belonging cards" do
    @column.cards.each do |card|
      @column.to_json.should include(card.name)
    end
  end

  it "should include cards with tag list" do
    card = Card.new(:name => "card test for tag list in json for column")
    card.tag_list.add('ala', 'ma', 'kota')

    column = Column.new
    column.cards << card
    column.cards.should have(1).records

    column.to_json.should include_text('"tag_list": ["ala", "ma", "kota"]')
  end

end

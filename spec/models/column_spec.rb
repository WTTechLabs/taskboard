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
      :taskboard_id => taskboards(:first_iteration).id
    }
  end

  it "should create a new instance given valid attributes" do
    Column.create!(@valid_attributes)
  end
end

describe Column, "while working with database" do
  fixtures :taskboards, :columns, :cards

  it "should have non-empty collection of columns" do
    Column.find(:all).should_not be_empty
  end
  
  it "should contain valid number of cards" do 
    column = columns(:todo)
    column.cards.should have(2).records
  end

  it "should allow inserting new column at given position" do
    column = Column.create!(:name => 'very new column', :taskboard_id => taskboards(:first_iteration).id)
    column.insert_at(3)
    column.higher_item.should eql(columns(:in_progress))
    column.lower_item.should eql(columns(:test_needed))
  end

  it "should define default name" do
    Column.default_name.should_not be_empty
  end
end

describe Column, "while serializing to json" do
  fixtures :columns, :cards

  before(:each) do
    @column = columns(:todo)	
  end

  it "should not include any dates" do
    @column.to_json.should_not include('created_at')
    @column.to_json.should_not include('updated_at')
  end

  it "should not include any references to foreign keys" do
    @column.to_json.should_not include('taskboard_id')
  end

  it "should include belonging cards" do
    @column.to_json.should include(cards(:coffee).name)
    @column.to_json.should include(cards(:firefox).name)
    @column.to_json.should_not include(cards(:sleep).name)
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

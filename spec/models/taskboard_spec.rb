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

describe Taskboard do
  fixtures :taskboards, :cards, :columns, :hours
  
  before(:each) do
    @valid_attributes = {
      :name => "Iteration 42"
    }
  end

  it "should create a new instance given valid attributes" do
    Taskboard.create!(@valid_attributes)
  end

  it "should not be valid with invalid name" do
    [nil, "", " ", "    " ].each { |invalid_name|
        taskboard = Taskboard.new(:name => invalid_name)
        taskboard.should_not be_valid 
    }
  end

  it "should define default name" do
    Taskboard::DEFAULT_NAME.should_not be_empty
  end

  it "should generate burndown data for whole taskboard" do
    taskboard = taskboards(:big_taskboard)
    
    cards_burndown = cards(:first_card_in_big).burndown.sort.map{|x| x[1] }
    taskboard.burndown.sort.map{|x| x[1] }.should eql(cards_burndown)
    
    taskboard.cards.first.update_hours(3)
    cards_burndown.push(3)
    taskboard.burndown.sort.map{|x| x[1] }.should eql(cards_burndown)
    
    taskboard.cards.last.update_hours(2)
    cards_burndown[-1] += 2
    taskboard.burndown.sort.map{|x| x[1] }.should eql(cards_burndown)
  end

end

describe Taskboard, "while cloning" do
  fixtures :taskboards, :cards, :columns

  it "should initialize right properties and perform cloning on cards" do
    taskboard = taskboards(:big_taskboard)
    clonned = taskboard.clone

    clonned.should_not eql(taskboard)
    clonned.name.should eql(taskboard.name)
    clonned.should have(6).cards

    first_column = columns(:first_column_in_big)
    first_clonned_column = clonned.columns.first
    first_clonned_column.position.should eql(first_column.position)

    first_card = cards(:sixth_card_in_big)
    first_clonned_card = clonned.columns[1].cards[1]

    first_clonned_card.should_not eql(first_card)
    first_clonned_card.name.should eql(first_card.name)
    first_clonned_card.url.should eql(first_card.url)
    first_clonned_card.issue_no.should eql(first_card.issue_no)
    first_clonned_card.position.should eql(first_card.position)

    first_clonned_card.taskboard_id.should_not eql(first_card.taskboard_id)
    first_clonned_card.column_id.should_not eql(first_card.column_id)
    first_clonned_card.row_id.should_not eql(first_card.row_id)

    first_clonned_card.taskboard_id.should eql(clonned.id)
    first_clonned_card.column_id.should eql(clonned.columns[1].id)
    first_clonned_card.row_id.should eql(clonned.rows.first.id)

    # check cards order
    positions = Hash[*clonned.cards.collect { |card| [card.name, card.position] }.flatten]
    positions['First card on big taskboard'].should eql(1)
    positions['Second card on big taskboard'].should eql(2)
    positions['Third card on big taskboard'].should eql(3)
    positions['4th card on big taskboard'].should eql(1)
    positions['5th card on big taskboard'].should eql(1)
    positions['6th card on big taskboard'].should eql(2)
  end

end

describe Taskboard, "while working with database" do
  fixtures :taskboards, :cards, :columns

  it "should have fixed number of cards assigned" do
    taskboard = taskboards(:big_taskboard)
    taskboard.should have(6).cards
  end

  it "should have valid number of columns (i.e. columns) assigned" do
    taskboard = taskboards(:big_taskboard)
    taskboard.should have(3).columns
  end

end

describe Taskboard, "while serializing to json" do
  fixtures :taskboards, :cards, :columns, :rows

  before(:each) do
    @taskboard = taskboards(:big_taskboard)	
  end

  it "should not include any dates" do
    @taskboard.to_json.should_not include('created_at')
    @taskboard.to_json.should_not include('updated_at')
  end
  
  it "should include belonging columns with cards" do
    @taskboard.to_json.should include(columns(:first_column_in_big).name)
    @taskboard.to_json.should include(columns(:second_column_in_big).name)
    @taskboard.to_json.should include(columns(:third_column_in_big).name)
    @taskboard.to_json.should include(cards(:first_card_in_big).name)
    @taskboard.to_json.should include(cards(:sixth_card_in_big).name)
  end

  it "should include belonging rows" do
    @taskboard.to_json.should include(rows(:first_row_in_big).name)
    @taskboard.to_json.should include(rows(:second_row_in_big).name)
  end

  it "should include cards with urls" do
    taskboard = taskboards(:big_taskboard)

    card = cards(:first_card_in_big)

    taskboard.to_json.should include_text('"name": "' + taskboard.name + '"')
    taskboard.to_json.should include_text('"url": "' + card.url + '"')
  end

  it "should include cards with tag list" do
    card = Card.new(:name => "card test for tag list in json for taskboard")
    card.tag_list.add('ala', 'ma', 'kota')

    column = Column.new
    column.cards << card
    column.cards.should have(1).records

    taskboard = Taskboard.new
    taskboard.columns << column
    taskboard.cards << card
    taskboard.columns.should have(1).records

    taskboard.to_json.should include_text('"tag_list": ["ala", "ma", "kota"]')
  end

  it "should include cards with hours left" do
    taskboards(:big_taskboard).to_json.should include_text('hours_left')
  end

  it "should include cards with hours updated date" do
    taskboards(:big_taskboard).to_json.should include_text('hours_left_updated')
  end

  it "should include cards with urls" do
    taskboard = taskboards(:big_taskboard)
    card = cards(:first_card_in_big)
    
    taskboard.to_json.should include_text('"name": "' + taskboard.name + '"')
    taskboard.to_json.should include_text('"url": "' + card.url + '"')
  end
  
end

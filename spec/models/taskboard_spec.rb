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
    taskboard = taskboards(:demo_taskboard)
    
    cards_burndown = cards(:demo_fun_hours_card).burndown.sort.map{|x| x[1] }
    taskboard.burndown.sort.map{|x| x[1] }.should eql(cards_burndown)
    
    taskboard.cards.first.update_hours(3)
    cards_burndown[cards_burndown.length - 1] += 3
    taskboard.burndown.sort.map{|x| x[1] }.should eql(cards_burndown)
    
    taskboard.cards.last.update_hours(2)
    cards_burndown[-1] += 2
    taskboard.burndown.sort.map{|x| x[1] }.should eql(cards_burndown)
  end

end

describe Taskboard, "while cloning" do
  fixtures :taskboards, :cards, :columns

  it "should initialize right properties and perform cloning on cards" do
    taskboard = taskboards(:scrum_taskboard)
    clonned = taskboard.clone

    clonned.should_not eql(taskboard)
    clonned.name.should eql(taskboard.name)
    clonned.project.should eql(taskboard.project)
    clonned.should have(taskboard.cards.size).cards

    taskboard.rows.each_with_index do |row, row_index|
      clonned_row = clonned.rows[row_index]

      clonned_row.name.should eql row.name
      clonned_row.position.should eql row.position
      clonned_row.should have(row.cards.size).cards
    end

    taskboard.columns.each_with_index do |column, column_index|
      clonned_column = clonned.columns[column_index]

      clonned_column.name.should eql column.name
      clonned_column.position.should eql column.position
      clonned_column.should have(column.cards.size).cards

      taskboard.rows.each_with_index do |row, row_index|
        clonned_row = clonned.rows[row_index]

        cards = column.cards.in_row(row)
        clonned_cards = clonned_column.cards.in_row(clonned_row)

        cards.each_with_index do |card, card_index|
          clonned_card = clonned_cards[card_index]

          clonned_card.should_not eql card
          clonned_card.name.should eql card.name
          clonned_card.url.should eql card.url
          clonned_card.issue_no.should eql card.issue_no
          clonned_card.position.should eql card.position

          clonned_card.taskboard.should_not eql card.taskboard
          clonned_card.column.should_not eql card.column
          clonned_card.row_id.should_not eql card.row

          clonned_card.taskboard.should eql clonned
          clonned_card.column.should eql clonned_column
          clonned_card.row.should eql clonned_row
        end
      end
    end

  end

end

describe Taskboard, "while working with database" do
  fixtures :taskboards, :cards, :columns

  it "should have fixed number of cards assigned" do
    taskboard = taskboards(:scrum_taskboard)
    taskboard.should have_at_least(1).card
  end

  it "should have fixed number of cards assigned" do
    taskboard = taskboards(:scrum_taskboard)
    taskboard.should have_at_least(1).card
  end

  it "should have valid number of rows assigned" do
    taskboard = taskboards(:scrum_taskboard)
    taskboard.should have_at_least(1).row
  end

end

describe Taskboard, "while serializing to json" do
  fixtures :taskboards, :cards, :columns, :rows

  before(:each) do
    @taskboard = taskboards(:scrum_taskboard)
  end

  it "should not include any dates" do
    @taskboard.to_json.should_not include('created_at')
    @taskboard.to_json.should_not include('updated_at')
  end
  
  it "should include belonging columns with cards" do
    @taskboard.columns.each do |column|
      @taskboard.to_json.should include(column.name)
    end
  end

  it "should include belonging rows" do
    @taskboard.rows.each do |row|
      @taskboard.to_json.should include(row.name)
    end
  end

  it "should include cards with urls" do
    taskboard = taskboards(:scrum_taskboard)

    card = cards(:scrum_story_user_card)

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
    taskboards(:scrum_taskboard).to_json.should include_text('hours_left')
  end

  it "should include cards with hours updated date" do
    taskboards(:scrum_taskboard).to_json.should include_text('hours_left_updated')
  end

end

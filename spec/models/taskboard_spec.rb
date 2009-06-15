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
  
  it "should generate burndown data for whole taskboard" do
    taskboard = taskboards(:first_iteration)
    
    cards_burndown = cards(:coffee).burndown.sort.map{|x| x[1] }
    taskboard.burndown.sort.map{|x| x[1] }.should eql(cards_burndown)
    
    taskboard.cards.first.update_hours(3)
    taskboard.burndown.sort.map{|x| x[1] }.should eql([30, 25, 28, 19, 9, 0, 3])
    
    taskboard.cards.last.update_hours(2)
    # last card has more hours causing extra zeros
    taskboard.burndown.sort.map{|x| x[1] }.should eql([30, 25, 28, 19, 9, 0, 0, 0, 0, 0, 0, 5])
  end
  
end

describe Taskboard, "while working with database" do
  fixtures :taskboards, :cards, :columns

  it "should have fixed number of cards assigned" do
    taskboard = taskboards(:first_iteration)
    taskboard.cards.should have(3).records
  end

  it "should have valid number of columns (i.e. columns) assigned" do
    taskboard = taskboards(:first_iteration)
    taskboard.columns.should have(4).records
  end

end

describe Taskboard, "while serializing to json" do
  fixtures :taskboards, :cards, :columns

  before(:each) do
    @taskboard = taskboards(:first_iteration)	
  end

  it "should not include any dates" do
    @taskboard.to_json.should_not include('created_at')
    @taskboard.to_json.should_not include('updated_at')
  end
  
  it "should include belonging columns with cards" do
    @taskboard.to_json.should include(columns(:todo).name)
    @taskboard.to_json.should include(columns(:in_progress).name)
    @taskboard.to_json.should include(cards(:sleep).name)
    @taskboard.to_json.should include(cards(:firefox).name)
  end

  it "should include cards with urls" do
    taskboard = taskboards(:first_iteration)

    firefox_card = cards(:firefox)

    taskboard.to_json.should include_text('"name": "'+taskboard.name+'"')
    taskboard.to_json.should include_text('"url": "'+firefox_card.url+'"')
  end

  it "should include cards with tag list" do
    card = Card.new(:name => "card test for tag list in json for taskboard")
    card.tag_list.add('ala', 'ma', 'kota')

    column = Column.new
    column.cards << card
    column.cards.should have(1).records

    taskboard = Taskboard.new
    taskboard.columns << column
    taskboard.columns.should have(1).records

    taskboard.to_json.should include_text('"tag_list": ["ala", "ma", "kota"]')
  end

  it "should include cards with hours left" do
    taskboards(:first_iteration).to_json.should include_text('hours_left')
  end

  it "should include cards with hours updated date" do
    taskboards(:first_iteration).to_json.should include_text('hours_left_updated')
  end

  it "should return card with url" do
    card = cards(:firefox)
    card.to_json.should include_text('"issue_no": "ISSUE-36')
    card.to_json.should include_text('"url": "http')

    taskboard = taskboards(:first_iteration)
    taskboar_descirption = taskboard.name

    taskboard.to_json.should include_text('"name": "' + taskboar_descirption + '"')
    taskboard.to_json.should include_text('"url": "http')
  end
  
end

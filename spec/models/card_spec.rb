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

describe Card do

  before(:each) do
    @valid_attributes = {
      :issue_no => 'ISSUE-3456',
      :name => 'Support for Firefox 3.0',
      :color => '#fc0fc0',
      :notes => 'This is test note for test card',
      :url => 'http://jira.example.com/jira/browse/ISSUE-3456'
    }
  end

  it "should create a new instance given valid attributes" do
    Card.create!(@valid_attributes)
  end

  it "should have url defined based on issue_no attribute" do
    card = Card.create!(@valid_attributes)
    card.url.should eql(@valid_attributes[:url])
  end

  it "should be taggable" do
    card = Card.new(@valid_attributes)
    card.tag_list.should be_empty
  end
  
  it "should have empty list of ideal hours left for new card" do
    card = Card.new
    card.hours.should be_empty
  end
  
  it "should have a issue no as a short name" do
    card = Card.create!(@valid_attributes)
    card.short_name.should eql(@valid_attributes[:issue_no])
  end
  
  it "should have a name as a short name if issue no is not defined" do
    card = Card.create!(@valid_attributes.except(:issue_no))
    card.short_name.should eql(@valid_attributes[:name])
  end

  it "should have a truncated name as a short name if it's too long" do
    card = Card.create!(@valid_attributes.except(:issue_no))
    card.name = "This is some very long name that needs to be shortened"
    card.short_name.should include("This is some very long")
    card.short_name.length.should eql(30)
  end

end

describe Card, "while creating new instance" do
  fixtures :cards, :hours

  it "should initialize right properties when clonning" do
    card = cards(:demo_tips_discover_card)
    card.tag_list.add("Big tag")
    card.tag_list.add("Small taggy")
    clonned = card.clone

    clonned.class.should be(Card)
    clonned.should_not eql(card)
    clonned.name.should eql(card.name)
    clonned.url.should eql(card.url)
    clonned.issue_no.should eql(card.issue_no)
    clonned.notes.should eql(card.notes)
    clonned.position.should eql(card.position)
    clonned.color.should eql(card.color)
    clonned.tag_list.should eql(card.tag_list)
    clonned.taskboard_id.should eql(card.taskboard_id)
    clonned.column_id.should eql(card.column_id)
    clonned.row_id.should eql(card.row_id)

    clonned = card.clone 123, 234, 345

    clonned.class.should be(Card)
    clonned.should_not eql(card)
    clonned.name.should eql(card.name)
    clonned.url.should eql(card.url)
    clonned.issue_no.should eql(card.issue_no)
    clonned.notes.should eql(card.notes)
    clonned.position.should eql(card.position)
    clonned.color.should eql(card.color)
    clonned.tag_list.should eql(card.tag_list)
    clonned.taskboard_id.should eql(123)
    clonned.column_id.should eql(234)
    clonned.row_id.should eql(345)
  end

end

describe Card, "while serializing to json" do
  fixtures :cards, :hours

  before(:each) do
    @valid_attributes = {
      :issue_no => 'ISSUE-3456',
      :name => 'Support for Firefox 3.0',
      :color => '#fc0fc0',
      :notes => 'Yet another test notes',
      :url => 'http://jira.example.com/jira/browse/ISSUE-3456'
    }
    @card = Card.create!(@valid_attributes)
  end

  it "should produce json valid for taskboard javascript application" do
    @card.to_json.should include(@valid_attributes[:url])
    @card.to_json.should include(@valid_attributes[:color])
    @card.to_json.should include(@valid_attributes[:issue_no])
    @card.to_json.should include(@valid_attributes[:notes])
    # TODO: other assertions if needed here
  end

  it "should not include issue_no when issue_no doesn't exist" do
    card = Card.create!(@valid_attributes.except(:issue_no))
    card.to_json.should_not include('issue_no')
  end

  it "should not include url and when doesn't exist" do
    card = Card.create!(@valid_attributes.except(:url))
    card.to_json.should_not include('url')
  end

  it "should have default color" do
    card = Card.create!(@valid_attributes.except(:color))
    card.to_json.should include('#F8E065')
  end

  it "should not include any dates and unneeded foreigh keys" do
    @card.to_json.should_not include('created_at')
    @card.to_json.should_not include('updated_at')
    @card.to_json.should_not include('taskboard_id')
  end

  it "should include references to column (for use while reordering cards)" do
    @card.to_json.should include('column_id')
  end

  it "should include references to row (for use while reordering cards)" do
    @card.to_json.should include('row_id')
  end

  it "should include all tags" do
    @card.to_json.should include('tag_list')
    @card.tag_list.add('ala', 'ma', 'kota')
    @card.to_json.should include('"tag_list": ["ala", "ma", "kota"]')
  end

  it "should include last hours left" do
    @card.to_json.should include('hours_left')

    @card.update_hours(666)
    @card.to_json.should include('"hours_left": 666')
  end

  it "should include last hours left update date" do
    @card.to_json.should include('hours_left_updated')

    @card.update_hours(666)
    today = Time.now.strftime("%Y-%m-%d")
    @card.to_json.should include('"hours_left_updated": "' + today)
  end

  it "should include cards with urls" do
    @card.to_json.should include_text('"issue_no": "' + @card.issue_no+ '"')
    @card.to_json.should include_text('"url": "' + @card.url + '"')
  end

end

describe Card, "while dealing with ideal hours" do
  fixtures :cards, :hours

  it "should have not empty list of ideal hours" do
    card = cards(:demo_fun_hours_card)
    card.should have_at_least(1).hour
  end

  it "should allow adding new hours" do
    card = cards(:demo_fun_hours_card)
    card.update_hours(4)
    
    card.hours.last.left.should eql(4)
  end

  it "should allow adding new hours to card without previous hours" do
    card = cards(:demo_fun_dragndrop_card)
    card.update_hours(44)

    card.hours.last.left.should eql(44)
    card.should have(1).hour
  end

  it "should have correct order of hours (by date)" do
    # TODO: refactor this test
    card = cards(:demo_fun_hours_card)
    card.hours[0].left.should eql(5)
    card.hours[1].left.should eql(3)
  end

  it "should update hours while adding another ones in same day" do
    card = cards(:demo_fun_hours_card)

    card.update_hours(3)
    card.hours.last.left.should eql(3)
    size = card.hours.size

    card.update_hours(5)
    card.hours.last.left.should eql(5)
    card.hours.size.should eql size # still same size, no new record
  end

  it "should update hours while adding another ones in same time" do
    card = cards(:demo_fun_hours_card)
    size = card.hours.size

    card.update_hours(33, card.hours.last.date)
    card.hours.last.left.should eql(33)
    card.hours.size.should eql size
  end

  it "should allow getting remaining hours quickly" do
    card = cards(:demo_fun_hours_card)
    card.hours_left.should eql card.hours.last.left
    card.update_hours(0)
    card.hours_left.should eql(0)
  end

  it "should have default value of remaining hours equal 0" do
    Card.new.hours_left.should eql(0)
  end

  it "should allow checking when the remaining hours were updated" do
    card = cards(:demo_fun_dragndrop_card)
    card.hours_left_updated.should eql(nil)
    card.update_hours(3)
    card.hours_left_updated.should_not eql(nil)
    diff = Time.now - card.hours_left_updated
    diff.to_i.should eql(0)
  end

  it "should have default value of remaining hours equal 0" do
    Card.new.hours_left_updated.should eql(nil)
  end

  it "should allow adding new hours in the past" do
    past = 7.days.ago

    card = cards(:demo_fun_hours_card)
    size = card.hours.size
    card.update_hours(4, past)

    card.hours.last.left.should eql(4)
    card.hours.last.date.should eql(past)
    card.hours.size.should eql size + 1
  end

  it "should allow updating hours in the past" do
    past = 7.days.ago

    card = cards(:demo_fun_hours_card)
    size = card.hours.size
    card.update_hours(4, past)

    card.hours.last.left.should eql(4)
    card.hours.last.date.should eql(past)
    card.hours.size.should eql size + 1

    newPast = 7.days.ago

    card.update_hours(6, newPast)

    card.hours.last.left.should eql(6)
    card.hours.last.date.should eql(past)
    card.hours.size.should eql size + 1
  end

  it "should allow updating hours in the antient past" do
    # TODO: refactor to make more fixtured independent
    past = 13.days.ago

    card = cards(:demo_fun_hours_card)
    card.update_hours(4, past)

    card.hours.sort_by{|h| h.date}.last.left.should eql(3)
    card.burndown.sort.map{|x| x[1] }.should eql([4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 3, 3])

    newPast = 13.days.ago

    card.update_hours(6, newPast)

    card.hours.sort_by{|h| h.date}.last.left.should eql(3)
    card.burndown.sort.map{|x| x[1] }.should eql([6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 5, 3, 3])
  end

  it "should generate valid burndown data" do
    card = cards(:demo_fun_color_card)
    card.update_hours(3)
    card.burndown.values.should eql([3])

    card = cards(:demo_fun_dragndrop_card)
    card.hours << Hour.new(:left => 10, :date => 2.days.ago)
    card.burndown.map{|x| x[1] }.should eql([10, 10, 10])

    card = cards(:demo_fun_hours_card)
    card.burndown.sort.map{|x| x[1] }.should eql([5, 3, 3])
  end

  it "should generate burndown data without gaps" do
    card = cards(:demo_fun_dragndrop_card)

    card.hours << Hour.new(:left => 10, :date => 10.days.ago )
    card.hours << Hour.new(:left => 7, :date => 8.days.ago )
    card.hours << Hour.new(:left => 5, :date => 4.days.ago )
    card.hours << Hour.new(:left => 3, :date => 2.days.ago )

    burndown = card.burndown

    expected_hours = [3,3,3,5,5,7,7,7,7,10,10]
    (10..0).each { |n|
      burndown[n.days.ago.strftime("%Y-%m-%d")].should eql(expected_hours[n])
    }
  end
end

describe Card, "while working with database" do
  fixtures :cards, :taskboards, :columns, :rows, :hours

  before(:each) do
    @taskboard = taskboards(:demo_taskboard)
    @column_1 = columns(:demo_adding_cards_column)
    @row_1 = rows(:demo_first_row)
    @column_2 = columns(:demo_fun_with_cards_column)
    @row_2 = rows(:demo_second_row)
  end

  it "should have non-empty collection of cards" do
    Card.find(:all).should_not be_empty
  end

  it "should allow inserting new card at given position" do
    cards = @column_1.cards.in_row(@row_1)
    card = Card.create!(:name => 'very new card',
        :taskboard_id => @taskboard.id,
        :column_id => @column_1.id,
        :row_id => @row_1.id)

    card.insert_at(2)
    card.higher_item.should eql cards.first
    card.lower_item.should eql cards.second
  end

  it "should reorder cards within same column and row" do
    cards = @column_1.cards.in_row(@row_1)
    card = cards.first

    card.move_to(@column_1.id, @row_1.id, 2)

    @column_1.cards.should include card
    @row_1.cards.should include card
    card.position.should eql 2
    card.higher_item.should eql cards.second
    card.lower_item.should eql cards.third
  end

  it "should reorder card in the same row and column if row and column ids are not provided" do
    cards = @column_1.cards.in_row(@row_1)
    card = cards.first

    card.move_to(nil, nil, 2)

    @column_1.cards.should include card
    @row_1.cards.should include card
    card.position.should eql 2
    card.higher_item.should eql cards.second
    card.lower_item.should eql cards.third
  end

  it "should allow moving card to new column in the same row" do
    source_cards = @column_1.cards.in_row(@row_1)
    target_cards = @column_2.cards.in_row(@row_1)
    card = source_cards.first

    card.move_to(@column_2.id, @row_1.id, 2)

    @column_1.cards.should_not include card
    @column_2.cards.should include card
    @row_1.cards.should include card
    card.position.should eql 2
    card.higher_item.should eql target_cards.first
    card.lower_item.should eql target_cards.second
  end

  it "should move a card in the same row if row id is not provided" do
    source_cards = @column_1.cards.in_row(@row_1)
    target_cards = @column_2.cards.in_row(@row_1)
    card = source_cards.first

    card.move_to(@column_2.id, nil, 2)

    @column_1.cards.should_not include card
    @column_2.cards.should include card
    @row_1.cards.should include card
    card.position.should eql 2
    card.higher_item.should eql target_cards.first
    card.lower_item.should eql target_cards.second
  end
  
  it "should allow moving card to new row in the same column" do
    source_cards = @column_2.cards.in_row(@row_2)
    target_cards = @column_2.cards.in_row(@row_1)
    card = source_cards.first

    card.move_to(@column_2.id, @row_1.id, 3)

    @column_2.cards.should include card
    @row_1.cards.should include card
    @row_2.cards.should_not include card
    card.position.should eql 3
    card.higher_item.should eql target_cards.second
    card.lower_item.should eql target_cards.third
  end

  it "should move a card in the same column if column id is not provided" do
    source_cards = @column_2.cards.in_row(@row_2)
    target_cards = @column_2.cards.in_row(@row_1)
    card = source_cards.first

    card.move_to(nil, @row_1.id, 3)

    @column_2.cards.should include card
    @row_1.cards.should include card
    @row_2.cards.should_not include card
    card.position.should eql 3
    card.higher_item.should eql target_cards.second
    card.lower_item.should eql target_cards.third
  end
  
  it "should allow moving card to new column and new row" do
    source_cards = @column_2.cards.in_row(@row_2)
    target_cards = @column_1.cards.in_row(@row_1)
    card = source_cards.first

    card.move_to(@column_1.id, @row_1.id, 2)

    @column_1.cards.should include card
    @column_2.cards.should_not include card
    @row_1.cards.should include card
    @row_2.cards.should_not include card
    card.position.should eql(2)
    card.higher_item.should eql(target_cards.first)
    card.lower_item.should eql(target_cards.second)
  end

  it "should allow adding new card at correct position" do
    @column = columns(:scrum_todo_column)
    @row = rows(:scrum_user_row)
    @card_1 = cards(:scrum_todo_animations_card)
    card = Card.add_new(@taskboard.id, @column.id, @row.id)

    card.position.should eql(1)
    card.lower_item.should eql(@card_1)
  end

  it "should allow adding new card with appropriate name and issue number" do
    @column = columns(:scrum_todo_column)
    @row = rows(:scrum_user_row)
    card = Card.add_new(@taskboard.id, @column.id, @row.id, 'New card name', 'ISSUE-1920')

    card.name.should eql('New card name')
    card.issue_no.should eql('ISSUE-1920')
  end
  
  it "should allow color changing" do
    card = cards(:demo_tips_discover_card)
    card.color.should eql(Card::DEFAULT_COLOR)
    card.change_color('#fc0fc0')
    card.color.should eql('#fc0fc0')
  end

  it "should validate color format" do
    card = cards(:demo_tips_discover_card)
    card.color.should eql(Card::DEFAULT_COLOR)
    card.change_color('not so valid').should be_false
  end

  it "should allow notes changing" do
    card = cards(:demo_tips_discover_card)
    card.notes = 'New notes'
    card.notes.should eql('New notes')
  end

  context "and dealing with list scope" do
  
    before(:each) do
      @card = Card.new(:name => 'Testing list scope')
    end
    
    it "should return valid scope context when row and column are nil" do
      @card.row_id = @card.column_id = nil
      @card.scope_condition.should eql("column_id IS NULL AND row_id IS NULL")
    end
    
    it "should return valid scope context when row is nil" do
      @card.row_id = nil
      @card.column_id = 35
      @card.scope_condition.should eql("column_id = 35 AND row_id IS NULL")
    end
    
    it "should return valid scope context when column is nil" do
      @card.row_id = 57
      @card.column_id = nil 
      @card.scope_condition.should eql("column_id IS NULL AND row_id = 57")

    end
    
    it "should return valid scope context when row and column are not nil" do
      @card.row_id = 42
      @card.column_id = 24
      @card.scope_condition.should eql("column_id = 24 AND row_id = 42")
    end
  end
end

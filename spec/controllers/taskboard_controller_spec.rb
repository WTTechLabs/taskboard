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

describe TaskboardController, "while showing taskboards list page" do

  it "should redirect to projects' list page" do
    get_as_editor 'index'
    response.should redirect_to(:action => 'index', :controller => 'project')
  end

end

describe TaskboardController, "while creating new taskboard" do

  integrate_views
  fixtures :projects, :taskboards, :columns, :cards

  it "should only allow adding new taskboards to existing project" do
    post_as_editor 'add_taskboard'
    flash[:error].should eql("You need to specify project id!")
    response.should redirect_to({ :action => 'index' })
  end

  it "should add taskboard with default name if name not given" do
    taskboard = Taskboard.new
    Taskboard.should_receive(:new).and_return(taskboard)
    post_as_editor 'add_taskboard', :project_id => projects(:sample_project).id
    taskboard.name.should eql Taskboard::DEFAULT_NAME
  end

  it "should allow adding new taskboards" do
    taskboard = Taskboard.new
    Taskboard.should_receive(:new).and_return(taskboard)
    taskboard.should_receive(:save!)
    post_as_editor 'add_taskboard', :project_id => projects(:sample_project).id, :name => 'new taskboard!'
    response.should redirect_to :controller => 'project', :action => 'index'
    taskboard.name.should eql 'new taskboard!'
    taskboard.project.should eql projects(:sample_project)
    taskboard.should have(1).column
    taskboard.should have(1).row
  end

  it "should not allow cloning taskboard when taskboard id is not defined" do
    post_as_editor 'clone_taskboard', :id => ''
    flash[:error].should eql "Source taskboard should be set!"
    response.should redirect_to :action => 'index'
  end

  it "should allow cloning taskboards" do
    taskboard = Taskboard.new(:name => "Some name")
    clonned = Taskboard.new
    clonned.id = 10
    Taskboard.should_receive(:find).with(2).twice.and_return(taskboard)
    taskboard.should_receive(:clone).and_return(clonned)
    clonned.should_receive(:save!)
    post_as_editor 'clone_taskboard', :id => '2'
    response.should redirect_to :controller => 'project', :action => 'index'
    clonned.name.should eql 'Copy of Some name'
  end

end

describe TaskboardController, "while showing single taskboard page" do

  integrate_views
  fixtures :taskboards, :columns, :rows, :cards

  before(:each) do
    # TODO: needed because of juggernaut helper
    request.stub!(:session_options).and_return({ :id => 'dummy' })
  end

  it "should show empty taskboard" do
    get_as_editor 'show'
    response.body.should include '<title>Taskboard</title>'
  end

  it "should request loading taskboard for given identifier" do
    get_as_editor 'show', :id => 1
    response.body.should match /\{\s*id\s*:\s*'1'\s*\}/ # {id: '1'}
  end

  it "should take care of taskboard identifier to be valid integer" do
    get_as_editor 'show', :id => 'hackme'
    response.body.should match /\{\s*id\s*:\s*'0'\s*\}/ # {id: '0'}
  end

  it "should include juggernaut snippet with correct channel" do
    get_as_editor 'show', :id => 645
    response.body.should include 'new Juggernaut'
    response.body.should match /"?channels"?\s*:\s*\[645\]/ # channels: [645]
  end

  it "should allow fetching whole serialized taskboard" do
    taskboard = Taskboard.new(:name => 'this is a taskboard')
    Taskboard.should_receive(:find).with(1).and_return(taskboard)
    post_as_editor 'get_taskboard', :id => 1
    response.should be_success
    response.body.decode_json["taskboard"]["name"].should eql "this is a taskboard"
  end

  it "should return burndown data" do
    taskboard = Taskboard.new

    Taskboard.should_receive(:find).with(1).and_return(taskboard)
    taskboard.should_receive(:burndown).and_return({"2008-10-12" => "10"})

    post_as_editor 'load_burndown', :id => '1'
    response.should be_success
    response.body.should include "1223762400000"
  end

  context "while dealing with taskboard name" do

    it "should allow changing name of the taskboard" do
      taskboard = Taskboard.new(:name => "old name")
      taskboard.id = 3
      Taskboard.should_receive(:find).with(3).and_return(taskboard)
      taskboard.should_receive(:save!)
      controller.should_receive(:sync_rename_taskboard).with(taskboard, hash_including(:before => "old name")).and_return("{ status: 'success' }")
      post_as_editor 'rename_taskboard', :id => 3, :name => 'new name'
      response.should be_success
      response.body.decode_json["status"].should eql 'success'
      taskboard.name.should eql 'new name'
    end

    it "should not allow empty taskboard name while renaming" do
      taskboard = Taskboard.new(:name => 'old')
      Taskboard.should_receive(:find).with(3).and_return(taskboard)
      post_as_editor 'rename_taskboard', :id => 3, :name => ''
      response.should be_success
      response.body.decode_json["status"].should eql 'error'
      taskboard.name.should eql 'old'
    end

    it "should not allow blank taskboard name while renaming" do
      taskboard = Taskboard.new(:name => 'old')
      Taskboard.should_receive(:find).with(3).and_return(taskboard)
      post_as_editor 'rename_taskboard', :id => 3, :name => '     '
      response.should be_success
      response.body.decode_json["status"].should eql 'error'
      taskboard.name.should eql 'old'
    end

  end
  
  context "while dealing with columns" do
  
    it "should allow adding new column" do
      new_column = Column.new(:name => 'New column', :taskboard_id => 1)
      Column.should_receive(:new).and_return(new_column)
      new_column.should_receive(:save!)
      new_column.should_receive(:insert_at).with(1)
      controller.should_receive(:sync_add_column).with(new_column).and_return("{ status: 'success' }")
      post_as_editor 'add_column', :name => new_column.name, :taskboard_id => new_column.taskboard_id
      response.should be_success
      response.body.decode_json["status"].should eql 'success'
    end
    
    it "should allow removing column" do
      column = Column.new(:taskboard_id => 3, :name => 'Column to be deleted')
      Column.should_receive(:find).with(56).and_return(column)
      column.should_receive(:remove_from_list)
      Column.should_receive(:delete).with(56)
      controller.should_receive(:sync_delete_column).with(column).and_return("{ status: 'success' }")
      post_as_editor 'remove_column', :id => '56'
      response.should be_success
      response.body.decode_json["status"].should eql 'success'
    end
    
    it "should allow column reordering" do
      column = Column.new(:taskboard_id => 43, :name => 'Column  to be moved', :position => 6)
      Column.should_receive(:find).with(13).and_return(column)
      column.should_receive(:insert_at).with(3)
      controller.should_receive(:sync_move_column).with(column, hash_including(:before => 6)).and_return("{ status: 'success' }")
      post_as_editor 'reorder_columns', :id => 13, :position => 3
      response.should be_success
      response.body.decode_json["status"].should eql 'success'
    end
    
    it "should allow column renaming" do
      column = Column.new(:name => 'Column', :taskboard_id => 8)
      Column.should_receive(:find).with(42).and_return(column)
      column.should_receive(:save!)
      controller.should_receive(:sync_rename_column).with(column, hash_including(:before => 'Column')).and_return("{ status: 'success' }")
      post_as_editor 'rename_column', :id => 42, :name => 'New name'
      response.should be_success
      response.body.decode_json["status"].should eql 'success'
      column.name.should eql 'New name'
    end

    it "should not allow empty column new name while renaming" do
      column = Column.new(:name => 'Column')
      Column.should_receive(:find).with(42).and_return(column)
      post_as_editor 'rename_column', :id => 42, :name => ''
      response.should be_success
      response.body.decode_json["status"].should eql 'error'
      column.name.should eql 'Column'
    end

  end

  context "while dealing with rows" do
    fixtures :taskboards, :rows

    it "should allow adding new row" do
      taskboard = taskboards(:scrum_taskboard)
      new_row = Row.new(:name => 'New row', :taskboard_id => taskboard.id)
      Row.should_receive(:new).and_return(new_row)
      new_row.should_receive(:save!)
      new_row.should_receive(:insert_at).with(taskboard.rows.size + 1)
      controller.should_receive(:sync_add_row).with(new_row).and_return("{ status: 'success' }")
      post_as_editor 'add_row', :name => new_row.name, :taskboard_id => taskboard.id
      response.should be_success
      response.body.decode_json["status"].should eql 'success'
    end

    it "should allow removing row" do
      row = Row.new(:taskboard_id => 7, :name => 'Row to be deleted')
      Row.should_receive(:find).with(34).and_return(row)
      row.should_receive(:remove_from_list)
      Row.should_receive(:delete).with(34)
      controller.should_receive(:sync_delete_row).with(row).and_return("{ status: 'success' }")
      post_as_editor 'remove_row', :id => '34'
      response.should be_success
      response.body.decode_json["status"].should eql 'success'
    end

  end
  
  context "while dealing with cards" do
  
    it "should allow removing card" do
      card = Card.new(:taskboard_id => 4, :name => 'Card to be deleted')
      Card.should_receive(:find).with(34).and_return(card)
      card.should_receive(:remove_from_list)
      Card.should_receive(:delete).with(34)
      controller.should_receive(:sync_delete_card).with(card).and_return("{ status: 'success' }")
      post_as_editor 'remove_card', :id => '34'
      response.should be_success
      response.body.decode_json["status"].should eql 'success'
    end
    
    it "should allow cards reordering" do
      card = Card.new(:taskboard_id => 77, :name => 'Card to be moved')
      card.column = Column.new
      Card.should_receive(:find).with(13).and_return(card)
      card.should_receive(:move_to).with(3, 4, 5)
      controller.should_receive(:sync_move_card).with(card, hash_including(:before)).and_return("{ status: 'success' }")
      post_as_editor 'reorder_cards', :id => 13, :column_id => 3, :row_id => 4, :position => 5
      response.should be_success
      response.body.decode_json["status"].should eql 'success'
    end
  
  end

  context "while dealing with login" do
  
    it "should redirect to login page if user is not logged" do
      post 'show'
      response.should redirect_to(:controller => "login", :action => "login")
      flash[:notice].should be_nil
    end

    it "should redirect to login page if user is not logged as editor" do
      post_as_viewer 'add_card', :name => 'Our brand new card', :taskboard_id => '2', :column_id => ''
      response.should redirect_to(:controller => "taskboard", :action => "index")
      flash[:notice].should eql "You do not have permission to do that!"
    end
  
  end

end

describe TaskboardController, "while adding new card" do

  integrate_views
  fixtures :taskboards, :columns, :rows, :cards
  
  before(:each) do
    TaskboardConfig.reset
    TaskboardConfig.instance.should_receive(:jira_auth_data).any_number_of_times.and_return({'some.url.com' => ''})

    @taskboard = taskboards(:scrum_taskboard)
    @taskboard_old_cards_size = @taskboard.cards.size
    
    @column = @taskboard.columns.first
    @row = @taskboard.rows.first
  end

  it "should allow adding new card" do   
    new_card = Card.new(:taskboard_id => @taskboard.id, :name => 'Our brand new card')
    Card.should_receive(:new).with(:taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id, :name => 'Our brand new card').and_return(new_card)
    controller.should_receive(:sync_add_cards).with([new_card]).and_return("{ status: 'success' }")

    post_as_editor 'add_card', :name => 'Our brand new card', :taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id
    response.should be_success
    response.body.decode_json["status"].should eql 'success'

    @taskboard.cards.size.should eql @taskboard_old_cards_size + 1
    new_card.column.should eql @column
    new_card.row.should eql @row
  end

  it "should allow adding new card from jira url" do
    new_card = Card.new(:taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id, :name => 'from jira', :issue_no => 'IST-4703',
      :url => 'http://some.url.com/jira/browse/IST-4703')

    JiraParser.should_receive(:fetch_cards).with('http://some.url.com/jira/browse/IST-4703').and_return(Array.[](new_card))
    controller.should_receive(:sync_add_cards).with([new_card]).and_return("{ status: 'success' }")

    post_as_editor 'add_card', :name => 'http://some.url.com/jira/browse/IST-4703', :taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id
    response.should be_success
    response.body.decode_json["status"].should eql 'success'

    @taskboard.cards.size.should eql @taskboard_old_cards_size + 1
    new_card.column.should eql @column
    new_card.row.should eql @row
  end

  it "shouldn't cause duplicates after adding new card from jira url" do
    old_card = Card.new(:taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id, :name => 'from jira', :issue_no => 'IST-4703', :url => 'http://some.url.com/jira/browse/IST-4703')
    old_card.save!

    @taskboard.cards.size.should eql @taskboard_old_cards_size + 1

    new_card = Card.new(:name => 'from jira', :issue_no => 'IST-4703', :url => 'http://some.url.com/jira/browse/IST-4703')

    JiraParser.should_receive(:fetch_cards).with('http://some.url.com/jira/browse/IST-4703').and_return(Array.[](new_card))

    post_as_editor 'add_card', :name => 'http://some.url.com/jira/browse/IST-4703', :taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id
    response.should be_success
    response.body.decode_json["status"].should eql 'success'

    @taskboard.cards.size.should eql @taskboard_old_cards_size + 1
  end

  it "should allow adding new card from jira filter" do
    new_cards = []

    3.times { |i| new_cards << Card.new(:name => "name #{i}", :issue_no => "ISSUE-#{i}", :url => "http://example.com/ISSUE-#{i}", :taskboard_id => @taskboard.id) }
    JiraParser.should_receive(:fetch_cards).with('http://some.url.com/jira/browse/IST-4703').and_return(new_cards)
    controller.should_receive(:sync_add_cards).with(new_cards).and_return("{ status: 'success' }")

    post_as_editor 'add_card', :name => 'http://some.url.com/jira/browse/IST-4703', :taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id
    response.should be_success
    response.body.decode_json["status"].should eql 'success'

    @taskboard.cards.size.should eql @taskboard_old_cards_size + 3
    new_cards.each { |card|
      card.column.should eql @column
      card.row.should eql @row
    }
  end

  it "should allow adding new card from url" do
    new_card = Card.new(:taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id, :name => 'http://example.com', :issue_no => 'example.com', :url => 'http://example.com')

    UrlParser.should_receive(:fetch_cards).with('http://example.com').and_return(Array.[](new_card))
    controller.should_receive(:sync_add_cards).with([new_card]).and_return("{ status: 'success' }")

    post_as_editor 'add_card', :name => 'http://example.com', :taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id
    response.should be_success
    response.body.decode_json["status"].should eql 'success'

    @taskboard.cards.size.should eql @taskboard_old_cards_size + 1
    new_card.row.should eql @row
    new_card.column.should eql @column
  end

  it "should allow adding new card with empty column_id" do
    new_column = Column.new(:name => "Some not empty name for column", :taskboard_id => @taskboard.id)
    new_column.id = 100

    new_card = Card.new(:taskboard_id => @taskboard.id, :name => 'Our brand new card')
    Card.should_receive(:new).with(:taskboard_id => @taskboard.id, :column_id => new_column.id, :row_id => @row.id, :name => 'Our brand new card').and_return(new_card)
    Column.should_receive(:new).and_return(new_column)
    controller.should_receive(:sync_add_column).with(new_column).and_return("{ status: 'success' }")
    controller.should_receive(:sync_add_cards).with([new_card]).and_return("{ status: 'success' }")

    post_as_editor 'add_card', :name => 'Our brand new card', :taskboard_id => @taskboard.id, :column_id => '', :row_id => @row.id
    response.should be_success
    response.body.decode_json["status"].should eql 'success'

    @taskboard.cards.size.should eql @taskboard_old_cards_size + 1
    new_card.row.should eql @row
    new_card.column.should eql new_column
  end

  it "should add a card to first row if row id is not provided" do
    new_card = Card.new(:taskboard_id => @taskboard.id, :name => 'Our brand new card')
    Card.should_receive(:new).with(:taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @taskboard.rows.first.id, :name => 'Our brand new card').and_return(new_card)
    controller.should_receive(:sync_add_cards).with([new_card]).and_return("{ status: 'success' }")

    post_as_editor 'add_card', :name => 'Our brand new card', :taskboard_id => @taskboard.id, :column_id => @column.id
    response.should be_success
    response.body.decode_json["status"].should eql 'success'

    @taskboard.cards.size.should eql @taskboard_old_cards_size + 1
    new_card.column.should eql @column
    new_card.row.should eql @taskboard.rows.first
  end
  
  it "should give an error message with error occurs" do
    column = @taskboard.columns.first
    error = RuntimeError.new "test"
    JiraParser.should_receive(:fetch_cards).with('http://some.url.com/jira/browse/IST-4703').and_raise(error)
    controller.should_not_receive(:sync_add_cards)

    post_as_editor 'add_card', :name => 'http://some.url.com/jira/browse/IST-4703', :taskboard_id => @taskboard.id, :column_id => column.id
    response.should be_success
    response.body.decode_json["status"].should eql 'error'    
  end
end

describe TaskboardController, "while checking demo restrictions" do

  it "should not add more than 5 taskboards to a single project" do
    Taskboard.should_receive(:count).and_return(5)
    controller.should_not_receive(:add_taskboard)

    post_as_editor 'add_taskboard', :project_id => 12, :name => 'new taskboard!'
    response.should redirect_to :controller => 'project', :action => 'index'
    flash[:error].should_not be_blank
  end

  it "should not clone more than 5 taskboards to a single project" do
    dummy = Taskboard.new(:project_id => 17)
    Taskboard.should_receive(:find).and_return(dummy)
    Taskboard.should_receive(:count).and_return(5)
    controller.should_not_receive(:clone_taskboard)

    post_as_editor 'clone_taskboard', :id => '2'
    response.should redirect_to :controller => 'project', :action => 'index'
    flash[:error].should_not be_blank
  end

end

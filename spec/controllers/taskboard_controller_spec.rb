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

  integrate_views
  fixtures :taskboards, :columns, :rows, :cards
  
  it "should show list of taskboards" do
    taskboards = [Taskboard.new, Taskboard.new]
    Taskboard.should_receive(:find).with(:all, {:order => "name"}).and_return(taskboards)
    get 'index', {}, {:user_id => 1, :editor => true}
    response.should be_success
  end

  it "should show list of taskboards for viewer" do
    taskboards = [Taskboard.new, Taskboard.new]
    Taskboard.should_receive(:find).with(:all, {:order => "name"}).and_return(taskboards)
    get 'index', {}, {:user_id => 2}
    response.should be_success
  end

end

describe TaskboardController, "while creating new taskboard" do

  integrate_views
  fixtures :taskboards, :columns, :cards

  it "should not allow adding new taskboards with empty name" do
    post 'add_taskboard', { :name => '' }, {:user_id => 1, :editor => true}
    flash[:error].should eql("Taskboard name cannot be empty!")
    response.should redirect_to({ :action => 'index' })
  end

  it "should allow adding new taskboards" do
    taskboard = Taskboard.new
    Taskboard.should_receive(:new).and_return(taskboard)
    taskboard.should_receive(:save!)
    post 'add_taskboard', { :name => 'new taskboard!' }, {:user_id => 1, :editor => true}
    response.should redirect_to("http://test.host/taskboard/show")
    taskboard.name.should eql('new taskboard!')
    taskboard.should have(1).column
    taskboard.should have(1).row
  end

  it "should not allow cloning taskboard with empty name and without selecting taskboard" do
    post 'clone_taskboard', { :taskboard_id => '2', :name => '' }, {:user_id => 1, :editor => true}
    flash[:error].should eql("Source taskboard and name should be set!")
    response.should redirect_to({ :action => 'index' })
  end

  it "should not allow cloning taskboard with empty name and without selecting taskboard" do
    post 'clone_taskboard', { :taskboard_id => '', :name => 'New name' }, {:user_id => 1, :editor => true}
    flash[:error].should eql("Source taskboard and name should be set!")
    response.should redirect_to({ :action => 'index' })
  end

  it "should allow cloning taskboards" do
    taskboard = Taskboard.new
    Taskboard.should_receive(:new).and_return(taskboard)
    taskboard.should_receive(:save!)
    post 'clone_taskboard', { :taskboard_id => '2', :name => 'Clon' }, {:user_id => 1, :editor => true}
    response.should redirect_to("http://test.host/taskboard/show")
    taskboard.name.should eql('Clon')
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
    get 'show', {}, {:user_id => 1, :editor => true, :user => User.new(:username => 'tester')}
    response.body.should include('<title>Taskboard</title>')
  end
  
  it "should request loading taskboard for given identifier" do
    get 'show',  { :id => 1 }, {:user_id => 1, :editor => true, :user => User.new(:username => 'tester')}
    response.body.should include("{ id : '1'}")
  end
  
  it "should take care of taskboard identifier to be valid integer" do
    get 'show', { :id => 'hackme' }, {:user_id => 1, :editor => true, :user => User.new(:username => 'tester')}
    response.body.should include("{ id : '0'}")
  end
  
  it "should include juggernaut snippet with correct channel" do
    get 'show',  { :id => 645 }, {:user_id => 1, :editor => true, :user => User.new(:username => 'tester')}
    response.body.should include('new Juggernaut')
    response.body.should include('"channels": [645]')
  end
  
  it "should allow fetching whole serialized taskboard" do
    taskboard = Taskboard.new(:name => 'this is a taskboard')
    Taskboard.should_receive(:find).with(1).and_return(taskboard)
    post 'get_taskboard', { :id => 1 }, {:user_id => 1, :editor => true}
    response.should be_success
    response.body.should include_text('"name": "this is a taskboard"')
  end
  
  it "should return burndown data" do
    taskboard = Taskboard.new

    Taskboard.should_receive(:find).with(1).and_return(taskboard)
    taskboard.should_receive(:burndown).and_return({"2008-10-12" => "10"})

    post 'load_burndown', { :id => '1'}, {:user_id => 1, :editor => true}
    response.should be_success
    response.body.should include_text("1223762400000")
  end

  context "while dealing with taskboard name" do
  
    it "should allow changing name of the taskboard" do
      taskboard = Taskboard.new(:name => "old name")
      taskboard.id = 3
      Taskboard.should_receive(:find).with(3).and_return(taskboard)
      taskboard.should_receive(:save!)
      controller.should_receive(:sync_rename_taskboard).with(taskboard, hash_including(:before => "old name")).and_return("{ status: 'success' }")
      post 'rename_taskboard', { :id => 3, :name => 'new name' }, {:user_id => 1, :editor => true}
      response.should be_success
      response.body.should include_text("status: 'success'")
      taskboard.name.should eql('new name')
    end
    
    it "should not allow empty taskboard name while renaming" do
      taskboard = Taskboard.new(:name => 'old')
      Taskboard.should_receive(:find).with(3).and_return(taskboard)
      post 'rename_taskboard', { :id => 3, :name => '' }, {:user_id => 1, :editor => true}
      response.should be_success
      response.body.should include_text("status: 'error'")
      taskboard.name.should eql('old')
    end

  end
  
  context "while dealing with columns" do
  
    it "should allow adding new column" do
      new_column = Column.new(:name => 'New column', :taskboard_id => 1)
      Column.should_receive(:new).and_return(new_column)
      new_column.should_receive(:save!)
      new_column.should_receive(:insert_at).with(1)
      controller.should_receive(:sync_add_column).with(new_column).and_return("{ status: 'success' }")
      post 'add_column', { :name => new_column.name, :taskboard_id => new_column.taskboard_id }, {:user_id => 1, :editor => true}
      response.should be_success
      response.body.should include_text("status: 'success'")
    end
    
    it "should allow removing column" do
      # TODO: make sure column is empty? make sure column belongs to given taskboard? how about foreign keys?
      column = Column.new(:taskboard_id => 3, :name => 'Column to be deleted')
      Column.should_receive(:find).with(56).and_return(column)
      column.should_receive(:remove_from_list)
      Column.should_receive(:delete).with(56)
      controller.should_receive(:sync_delete_column).with(column).and_return("{ status: 'success' }")
      post 'remove_column', { :id => '56' }, {:user_id => 1, :editor => true}
      response.should be_success
      response.body.should include_text("status: 'success'")
    end
    
    it "should allow column reordering" do
      column = Column.new(:taskboard_id => 43, :name => 'Column  to be moved', :position => 6)
      Column.should_receive(:find).with(13).and_return(column)
      column.should_receive(:insert_at).with(3)
      controller.should_receive(:sync_move_column).with(column, hash_including(:before => 6)).and_return("{ status: 'success' }")
      post 'reorder_columns', { :id => 13, :position => 3 }, {:user_id => 1, :editor => true}
      response.should be_success
      response.body.should include_text("status: 'success'")
    end
    
    it "should allow column renaming" do
      column = Column.new(:name => 'Column', :taskboard_id => 8)
      Column.should_receive(:find).with(42).and_return(column)
      column.should_receive(:save!)
      controller.should_receive(:sync_rename_column).with(column, hash_including(:before => 'Column')).and_return("{ status: 'success' }")
      post 'rename_column', { :id => 42, :name => 'New name' }, {:user_id => 1, :editor => true}
      response.should be_success
      response.body.should include_text("status: 'success'")
      column.name.should == 'New name'
    end

    it "should not allow empty column new name while renaming" do
      column = Column.new(:name => 'Column')
      Column.should_receive(:find).with(42).and_return(column)
      post 'rename_column', { :id => 42, :name => '' }, {:user_id => 1, :editor => true}
      response.should be_success
      response.body.should include_text("status: 'error'")
      column.name.should eql('Column')
    end
 
  end
  
  context "while dealing with cards" do
  
    it "should allow removing card" do
      # TODO: make sure card belongs to given taskboard? how about foreign keys?
      card = Card.new(:taskboard_id => 4, :name => 'Card to be deleted')
      Card.should_receive(:find).with(34).and_return(card)
      card.should_receive(:remove_from_list)
      Card.should_receive(:delete).with(34)
      controller.should_receive(:sync_delete_card).with(card).and_return("{ status: 'success' }")
      post 'remove_card', { :id => '34' }, {:user_id => 1, :editor => true}
      response.should be_success
      response.body.should include_text("status: 'success'")
    end
    
    it "should allow cards reordering" do
      card = Card.new(:taskboard_id => 77, :name => 'Card to be moved')
      card.column = Column.new
      Card.should_receive(:find).with(13).and_return(card)
      card.should_receive(:move_to).with(3, 4, 5)
      controller.should_receive(:sync_move_card).with(card, hash_including(:before)).and_return("{ status: 'success' }")
      post 'reorder_cards', { :id => 13, :column_id => 3, :row_id => 4, :position => 5 }, {:user_id => 1, :editor => true}
      response.should be_success
      response.body.should include_text("status: 'success'")
    end
  
  end

  context "while dealing with login" do
  
    it "should redirect to login page if user is not logged" do
      post 'show'
      response.should redirect_to(:controller => "login", :action => "login")
      assert_nil flash[:notice]
    end

    it "should redirect to login page if user is not logged as editor" do
      post 'add_card', { :name => 'Our brand new card', :taskboard_id => '2', :column_id => ''}, {:user_id => 2, :editor => false}
      response.should redirect_to(:controller => "taskboard", :action => "index")
      assert_equal "You do not have permission to do that!", flash[:notice]
    end
  
  end

end

describe TaskboardController, "while adding new card" do

  integrate_views
  fixtures :taskboards, :columns, :rows, :cards
  
  before(:each) do
    TaskboardConfig.reset
	TaskboardConfig.instance.should_receive(:jira_auth_data).any_number_of_times.and_return({'some.url.com' => ''})

    @taskboard = taskboards(:big_taskboard)
    @taskboard_old_cards_size = @taskboard.cards.size
    
    @column = @taskboard.columns.first
    @row = @taskboard.rows.first
  end

  it "should allow adding new card" do   
    new_card = Card.new(:taskboard_id => @taskboard.id, :name => 'Our brand new card')
    Card.should_receive(:new).with(:taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id, :name => 'Our brand new card').and_return(new_card)
    controller.should_receive(:sync_add_cards).with([new_card]).and_return("{ status: 'success' }")

    post 'add_card', { :name => 'Our brand new card', :taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id }, {:user_id => 1, :editor => true}
    response.should be_success
    response.body.should include_text("status: 'success'")

    @taskboard.cards.size.should eql(@taskboard_old_cards_size + 1)
    new_card.column.should eql(@column)
    new_card.row.should eql(@row)    
  end

  it "should allow adding new card from jira url" do
    new_card = Card.new(:taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id, :name => 'from jira', :issue_no => 'IST-4703',
      :url => 'http://some.url.com/jira/browse/IST-4703')

    JiraParser.should_receive(:fetch_cards).with('http://some.url.com/jira/browse/IST-4703').and_return(Array.[](new_card))
    controller.should_receive(:sync_add_cards).with([new_card]).and_return("{ status: 'success' }")

    post 'add_card', { :name => 'http://some.url.com/jira/browse/IST-4703', :taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id }, {:user_id => 1, :editor => true}
    response.should be_success
    response.body.should include_text("status: 'success'")

    @taskboard.cards.size.should eql(@taskboard_old_cards_size + 1)
    new_card.column.should eql(@column)
    new_card.row.should eql(@row)   
  end

  it "shouldn't cause duplicates after adding new card from jira url" do
    old_card = Card.new(:taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id, :name => 'from jira', :issue_no => 'IST-4703', :url => 'http://some.url.com/jira/browse/IST-4703')
    old_card.save!

    @taskboard.cards.size.should eql(@taskboard_old_cards_size + 1)

    new_card = Card.new(:name => 'from jira', :issue_no => 'IST-4703', :url => 'http://some.url.com/jira/browse/IST-4703')

    JiraParser.should_receive(:fetch_cards).with('http://some.url.com/jira/browse/IST-4703').and_return(Array.[](new_card))

    post 'add_card', { :name => 'http://some.url.com/jira/browse/IST-4703', :taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id }, {:user_id => 1, :editor => true}
    response.should be_success
    response.body.should include_text("status : 'success'")

    @taskboard.cards.size.should eql(@taskboard_old_cards_size + 1)
  end

  it "should allow adding new card from jira filter" do
    new_cards = []

    3.times { |i| new_cards << Card.new(:name => "name #{i}", :issue_no => "ISSUE-#{i}", :url => "http://example.com/ISSUE-#{i}", :taskboard_id => @taskboard.id) }
    JiraParser.should_receive(:fetch_cards).with('http://some.url.com/jira/browse/IST-4703').and_return(new_cards)
    controller.should_receive(:sync_add_cards).with(new_cards).and_return("{ status: 'success' }")

    post 'add_card', { :name => 'http://some.url.com/jira/browse/IST-4703',
      :taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id }, {:user_id => 1, :editor => true}
    response.should be_success
    response.body.should include_text("status: 'success'")

    @taskboard.cards.size.should eql(@taskboard_old_cards_size + 3)
    new_cards.each { |card|
      card.column.should eql(@column)
      card.row.should eql(@row)
    }
  end

  it "should allow adding new card from url" do
    new_card = Card.new(:taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id, :name => 'http://example.com', :issue_no => 'example.com', :url => 'http://example.com')

    UrlParser.should_receive(:fetch_cards).with('http://example.com').and_return(Array.[](new_card))
    controller.should_receive(:sync_add_cards).with([new_card]).and_return("{ status: 'success' }")

    post 'add_card', { :name => 'http://example.com', :taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @row.id }, {:user_id => 1, :editor => true}
    response.should be_success
    response.body.should include_text("status: 'success'")

    @taskboard.cards.size.should eql(@taskboard_old_cards_size + 1)
    new_card.row.should eql(@row)
    new_card.column.should eql(@column)
  end

  it "should allow adding new card with empty column_id" do
    new_column = Column.new(:name => "Some not empty name for column", :taskboard_id => @taskboard.id)
    new_column.id = 100

    new_card = Card.new(:taskboard_id => @taskboard.id, :name => 'Our brand new card')
    Card.should_receive(:new).with(:taskboard_id => @taskboard.id, :column_id => new_column.id, :row_id => @row.id, :name => 'Our brand new card').and_return(new_card)
    Column.should_receive(:new).and_return(new_column)
    controller.should_receive(:sync_add_column).with(new_column).and_return("{ status: 'success' }")
    controller.should_receive(:sync_add_cards).with([new_card]).and_return("{ status: 'success' }")

    post 'add_card', { :name => 'Our brand new card', :taskboard_id => @taskboard.id, :column_id => '', :row_id => @row.id }, {:user_id => 1, :editor => true}
    response.should be_success
    response.body.should include_text("status: 'success'")

    @taskboard.cards.size.should eql(@taskboard_old_cards_size + 1)
    new_card.row.should eql(@row)
    new_card.column.should eql(new_column)
  end

  it "should add a card to first row if row id is not provided" do
    new_card = Card.new(:taskboard_id => @taskboard.id, :name => 'Our brand new card')
    Card.should_receive(:new).with(:taskboard_id => @taskboard.id, :column_id => @column.id, :row_id => @taskboard.rows.first.id, :name => 'Our brand new card').and_return(new_card)
    controller.should_receive(:sync_add_cards).with([new_card]).and_return("{ status: 'success' }")

    post 'add_card', { :name => 'Our brand new card', :taskboard_id => @taskboard.id, :column_id => @column.id }, {:user_id => 1, :editor => true}
    response.should be_success
    response.body.should include_text("status: 'success'")

    @taskboard.cards.size.should eql(@taskboard_old_cards_size + 1)
    new_card.column.should eql(@column)
    new_card.row.should eql(@taskboard.rows.first)  
  end
  
  it "should give an error message with error occurs" do
    column = @taskboard.columns.first
    error = RuntimeError.new "test"
    JiraParser.should_receive(:fetch_cards).with('http://some.url.com/jira/browse/IST-4703').and_raise(error)
    controller.should_not_receive(:sync_add_cards)

    post 'add_card', { :name => 'http://some.url.com/jira/browse/IST-4703',
      :taskboard_id => @taskboard.id, :column_id => column.id }, {:user_id => 1, :editor => true}
    response.should be_success
    response.body.should include_text("status: 'error'")    
  end
end

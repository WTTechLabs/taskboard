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
require 'utils'
require 'jira_parser'
require 'jira_integration'

describe JiraParser, "while helping with url recognition" do

  it "should recognize valid jira urls" do
    TaskboardConfig.reset
    TaskboardConfig.instance.should_receive(:jira_auth_data).any_number_of_times.
      and_return({'jira.example.com' => '', 'jira.other.example.com' => ''})

    JiraParser.is_jira_url('http://jira.example.com/jira/browse/ISSUE-4703').should be_true
    JiraParser.is_jira_url('http://jira.example.com/jira').should be_true
    JiraParser.is_jira_url('http://jira.other.example.com/jira/browse/TASKBOARD-12').should be_true
    JiraParser.is_jira_url('My new story!').should be_false
  end
   
end

describe JiraParser do

  it "should response to :fetch_cards method" do
    JiraParser.should respond_to(:fetch_cards)
  end
  
  it "should fetch and parse xml for given url" do
    xml = get_file_as_string(File.expand_path(File.dirname(__FILE__) + '/../fixtures/jira-issue-01.xml'))
    url = 'http://jira.example.com/jira/browse/ISSUE-4703'
    JiraIntegration.should_receive(:get).with(url).and_return(xml)
    cards = JiraParser.fetch_cards(url)
    cards.size.should eql(1)
    cards.first.name.should eql('Table name case')
    cards.first.issue_no.should eql('ISSUE-12')
  end
  
  it "should return proper error in case of broken xml" do
    xml = 'i am broken xml'
    url = 'http://jira.example.com/jira/browse/broken'
    JiraIntegration.should_receive(:get).with(url).and_return(xml)

    lambda {
      cards = JiraParser.fetch_cards(url)
    }.should raise_error(RuntimeError)
  end
end

describe JiraParser, "while dealing with single issue" do
  
  before :all do
    @jira = JiraParser.new
    # uncomment to get execution time in test results
    # time 'reading file with issue' do
      @jira.xml = get_file_as_string(File.expand_path(File.dirname(__FILE__) + '/../fixtures/jira-issue-01.xml'))
    # end
    # time 'parsing jira' do
      @jira.do_parse!
    # end
  end
  
  it "should have size of 1" do
    @jira.issues.size.should eql(1)
  end
  
  it "should recognize issue number" do
    @jira.issues.first.issue_no.should eql("ISSUE-12")
  end
  
  it "should recognize issue name" do
    @jira.issues.first.name.should eql("Table name case")
  end

  it "should recognize issue url" do
    @jira.issues.first.url.should eql("http://jira.example.com/jira/browse/ISSUE-12")
  end

end

describe JiraParser, "while dealing with filters" do

  before :all do
    @jira = JiraParser.new
    # uncomment to get execution time in test results
    # time 'reading file with filter' do 
      @jira.xml = get_file_as_string(File.expand_path(File.dirname(__FILE__) + '/../fixtures/jira-filter-01.xml'))
    # end
    # time 'parsing jira' do
      @jira.do_parse!
    # end
  end
  
  it "should have size of 3" do
    @jira.issues.size.should eql(3)
  end
  
  it "should recognize issue number" do
    @jira.issues[2].issue_no.should eql("ISSUE-13")
  end
  
  it "should recognize issue name" do
    @jira.issues[2].name.should eql("Background colour")
  end
  
end


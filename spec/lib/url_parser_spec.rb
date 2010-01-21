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
require 'url_parser'

describe UrlParser, "while helping with url recognition" do

  it "should recognize valid urls" do
    [ 'https://jira.cognifide.com/jira/browse/TASKBOARD-2',
      'https://localhost:3000/app', 'http://google.com',
      'http://google.com'].each do |url|
      UrlParser.is_url(url).should be_true
    end
    
    UrlParser.is_url('My new card!').should be_false
  end

end

describe UrlParser do

  it "should response to :fetch_cards method" do
    UrlParser.should respond_to(:fetch_cards)
  end

  it "should fetch a card for given url" do
    url = 'https://jira.cognifide.com/jira/browse/TASKBOARD-2'
    cards = UrlParser.fetch_cards(url)
    cards.size.should eql(1)
    cards.first.name.should eql(url)
    cards.first.issue_no.should eql('TASKBOARD-2')
    cards.first.url.should eql(url)
  end

end

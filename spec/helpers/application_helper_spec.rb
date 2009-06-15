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

include ApplicationHelper

describe ApplicationHelper do

  it "should make time" do
    make_time("2008-10-12").should eql(1223762400)
    make_time("2006-04-29").should eql(1146261600)
    make_time("2014-07-04").should eql(1404424800)
  end

  it "should build proper javascript data structure from empty burndown hash" do
    burndown = burndown(Card.new)
    burndown.should include_text("[]")    
  end

  it "should build proper javascript data structure from not-empty burndown hash" do
    card = Card.new

    card.hours << Hour.new(:date => 5.days.ago, :left => 13)
    card.hours << Hour.new(:date => 3.days.ago, :left => 8)
    card.hours << Hour.new(:date => 1.day.ago, :left => 3)

    burndown(card).should match(/\[\[\d+,\s13\],\s\[\d+,\s13\],\s\[\d+,\s8\],\s\[\d+,\s8\],\s\[\d+,\s3\],\s\[\d+,\s3\]\]/)
  end

  it "should build proper javascript timestamp" do
    card = Card.new

    tics = make_time("2008-12-18").to_i * 1000

    card.hours << Hour.new(:date => "2008-12-18", :left => 10)

    burndown(card).should include(tics.to_s)
  end
  
end

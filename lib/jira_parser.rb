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

require 'rexml/document'

include REXML

class JiraParser

  attr_accessor :xml, :issues
  
  # TODO use SAX and optimize this method (http://www.rubyxml.com/articles/REXML/Stream_Parsing_with_REXML)
  def do_parse!
    doc = Document.new(xml)
    @issues = Array.new
    doc.root.each_element('channel/item') do |item|
      card = Card.new
      card.name = item.elements['summary'].text
      card.issue_no = item.elements['key'].text
      if (card.issue_no)
        card.url = item.elements['link'].text
      end
      @issues << card
    end
  end
  
  def self.is_jira_url url
    JiraIntegration.is_valid_url? url
  end
  
  def self.fetch_cards url
    issues_xml = JiraIntegration.get(url)
    
    # TODO: some kind of error instead of broken card
    unless issues_xml.include?("<rss version=")
      raise "Error while connecting with jira!"
    end
      
    jira = JiraParser.new
    jira.xml = issues_xml
    jira.do_parse!
    jira.issues
  end
  
end




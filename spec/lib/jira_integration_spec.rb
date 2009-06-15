# Copyright (C) 2009 Cognifide
# 
# This file is part of Taskboard.
# 
# Taskboard is free software: you can redISSUEribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# Taskboard is dISSUEributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Taskboard. If not, see <http://www.gnu.org/licenses/>.

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'net/http'
require 'net/https'
require 'utils'
require 'uri'
require 'jira_integration'

describe JiraIntegration, "while downloading file" do

  it "should return valid content for given url" do
    uri = URI.parse('http://jira.example.com/site')
    JiraIntegration.should_receive(:get_uri_to_xml).with('http://jira.example.com/site').and_return(uri)
    JiraIntegration.should_receive(:auth_data).and_return({ "jira.example.com" => { "os_username" => "user", "os_password" => "pass" }})
    http = Net::HTTP.new(uri.host, uri.port)
    Net::HTTP.should_receive(:new).with(uri.host, uri.port).and_return(http)
    request = Object.new
    request.should_receive(:body).and_return('Some data')
    http.should_receive(:get).with(uri.path + '?os_password=pass&os_username=user').and_return(request)

    data = JiraIntegration.get('http://jira.example.com/site')

    data.should eql('Some data')
    uri.query.should eql('os_password=pass&os_username=user')
  end

  it "should return valid content for given url with query" do
    uri = URI.parse('http://jira.example.com/site?query_id=12')
    JiraIntegration.should_receive(:get_uri_to_xml).with('http://jira.example.com/site?query_id=12').and_return(uri)
    JiraIntegration.should_receive(:auth_data).and_return({ "jira.example.com" => { "os_username" => "user", "os_password" => "pass" }})
    
    http = Net::HTTP.new(uri.host, uri.port)
    Net::HTTP.should_receive(:new).with(uri.host, uri.port).and_return(http)
    request = Object.new
    request.should_receive(:body).and_return('Some data')
    http.should_receive(:get).with(uri.path + '?query_id=12&os_password=pass&os_username=user').and_return(request)

    data = JiraIntegration.get('http://jira.example.com/site?query_id=12')

    data.should eql('Some data')
    uri.query.should eql('query_id=12&os_password=pass&os_username=user')
  end
end

describe JiraIntegration, "while parsing issue uri" do

  it "should return valid uri to jira xml" do
    uri = JiraIntegration.get_uri_to_xml('http://jira.example.com/jira/si/jira.issueviews:issue-xml/ISSUE-4703/ISSUE-4703.xml')
    uri.should eql(URI.parse('http://jira.example.com/jira/si/jira.issueviews:issue-xml/ISSUE-4703/ISSUE-4703.xml'))

    uri = JiraIntegration.get_uri_to_xml('http://jira.example.com/jira/si/jira.issueviews:issue-xml/ISSUE-4703/ISSUE-4703.xml?some_query=true&param=value')
    uri.should eql(URI.parse('http://jira.example.com/jira/si/jira.issueviews:issue-xml/ISSUE-4703/ISSUE-4703.xml?some_query=true&param=value'))
  end

  it "should parse http url to xml url" do
    uri = JiraIntegration.get_uri_to_xml('http://jira.example.com/jira/browse/ISSUE-4703')
    uri.should eql(URI.parse('http://jira.example.com/jira/si/jira.issueviews:issue-xml/ISSUE-4703/ISSUE-4703.xml'))

    uri = JiraIntegration.get_uri_to_xml('http://jira.example.com/jira/browse/ISSUE-4703?some_query=true&param=value')
    uri.should eql(URI.parse('http://jira.example.com/jira/si/jira.issueviews:issue-xml/ISSUE-4703/ISSUE-4703.xml?some_query=true&param=value'))
  end

end

describe JiraIntegration, "while parsing filter uri" do

  it "should return valid uri to jira filter xml" do
    uri = JiraIntegration.get_uri_to_xml('http://jira.example.com/jira/sr/jira.issueviews:searchrequest-xml/10946/SearchRequest-10946.xml?tempMax=1000')
    uri.should eql(URI.parse('http://jira.example.com/jira/sr/jira.issueviews:searchrequest-xml/10946/SearchRequest-10946.xml?tempMax=1000'))
  end

  it "should parse jira filter url to xml url" do
    uri = JiraIntegration.get_uri_to_xml('http://jira.example.com/jira/secure/IssueNavigator.jspa?mode=hide&requestId=10946')
    uri.should eql(URI.parse('http://jira.example.com/jira/sr/jira.issueviews:searchrequest-xml/10946/SearchRequest-10946.xml?tempMax=1000'))
  end

end

describe JiraIntegration, "while parsing search uri" do

  it "should return valid uri to jira filter xml" do
    uri = JiraIntegration.get_uri_to_xml('http://jira.example.com/jira/sr/jira.issueviews:searchrequest-xml/temp/SearchRequest.xml?&pid=10020&assigneeSelect=issue_current_user&sorter/field=issuekey&sorter/order=DESC&tempMax=1000')
    uri.should eql(URI.parse('http://jira.example.com/jira/sr/jira.issueviews:searchrequest-xml/temp/SearchRequest.xml?&pid=10020&assigneeSelect=issue_current_user&sorter/field=issuekey&sorter/order=DESC&tempMax=1000'))
  end

  it "should parse jira search url to xml url" do
    uri = JiraIntegration.get_uri_to_xml('http://jira.example.com/jira/secure/IssueNavigator.jspa?reset=true&pid=10020&assigneeSelect=issue_current_user&sorter/field=issuekey&sorter/order=DESC')
    uri.should eql(URI.parse('http://jira.example.com/jira/sr/jira.issueviews:searchrequest-xml/temp/SearchRequest.xml?&pid=10020&assigneeSelect=issue_current_user&sorter/field=issuekey&sorter/order=DESC&tempMax=1000'))
  end

  #
end


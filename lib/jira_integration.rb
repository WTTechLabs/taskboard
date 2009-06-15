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

require 'net/http'
require 'net/https'
require 'uri'
require 'taskboard_config'

class JiraIntegration

  def self.get url
    uri = get_uri_to_xml(url)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if uri.port == Net::HTTP.https_default_port

    # append credentials
    credentials = self.auth_data[uri.host].to_a.collect{ |a| a.join('=') }.join('&')
    uri.query = uri.query.nil? ? credentials : uri.query + '&' + credentials

    http.get(uri.path + '?' + uri.query).body
  end

  def self.get_uri_to_xml url
    uri = URI.parse(url)

    # leave all request to xml file untouched
    unless uri.path.ends_with?('.xml')

      # check if it is request for single issue or bunch of them (IssueNavigator)
      if uri.path =~ /secure\/IssueNavigator.jspa/
        
        # distinguish between search results and filters
        if uri.query =~ /requestId=[\d]*$/

          # parse filter id
          filter_id = uri.query[/requestId=[\d]*$/][/\d+/]
          uri.path.sub!('secure/IssueNavigator.jspa',
            'sr/jira.issueviews:searchrequest-xml/' + filter_id + '/SearchRequest-' + filter_id + '.xml')
        else

          # just modify path
          uri.path.sub!('secure/IssueNavigator.jspa',
            'sr/jira.issueviews:searchrequest-xml/temp/SearchRequest.xml')
        end

        # remove 'mode' and 'requestId' parameters and add 'tempMax'
        uri.query.gsub!(/&?(mode=\w+|requestId=\w+|reset=\w+)/, '')
        uri.query += '&' unless uri.query.empty?
        uri.query += 'tempMax=1000'

      else
        # single issue
        issue_id = uri.path[/[\w-]*$/]
        uri.path = uri.path.sub('browse', 'si/jira.issueviews:issue-xml') + '/' + issue_id + '.xml'
      end
    end
    uri
  end
  
  def self.is_valid_url? url
    not self.auth_data.nil? and self.auth_data.keys.any? { |base| url.include? base }
  end

  private
  
    def self.auth_data
      TaskboardConfig.instance.jira_auth_data
    end
end


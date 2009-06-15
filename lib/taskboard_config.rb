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

require 'yaml'
require 'utils'

class TaskboardConfig
  attr_accessor :jira_auth_data;

  def self.instance
    if @config.nil?
      @config_file_name = "config/taskboard.yml"
      @config = YAML.load_file(@config_file_name)
    end
    @config

  rescue Errno::ENOENT => e
    # TODO: log some error? -- but not with 'puts'
    @config = TaskboardConfig.new
  end

  # only for testing
  def self.reset
    @config = nil
  end
  
end

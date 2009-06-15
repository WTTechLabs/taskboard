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

class Column < ActiveRecord::Base
  belongs_to :taskboard
  has_many :cards

  acts_as_list :scope => :taskboard

  def to_json options = {}
    options[:include] = { :cards => { :methods => [:tag_list, :hours_left, :hours_left_updated] }}
    options[:except] = [:created_at, :updated_at, :taskboard_id]
    super(options)
  end

  def self.default_name
    'Brave new column'
  end
end

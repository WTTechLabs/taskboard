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

class Taskboard < ActiveRecord::Base
  has_many :cards
  has_many :columns

  def burndown
    burndown = Hash.new(0)
    self.cards.each { |card|
      card.burndown.each_pair { |date, hours|
        burndown[date] += hours
      }
    }

    return burndown
  end
  
  def to_json options = {}
    options[:include] = { :columns => { :include => { :cards => { :methods => [:tag_list, :hours_left, :hours_left_updated] }}}}
    options[:except] = [:created_at, :updated_at]
    super(options)
  end
end

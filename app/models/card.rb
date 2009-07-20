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

class Card < ActiveRecord::Base
  include ActionView::Helpers::TextHelper # to truncate short name
  
  has_many :hours, :order => "date asc"
  belongs_to :taskboard
  belongs_to :column
  belongs_to :row
  
  DEFAULT_COLOR = '#F8E065'.freeze

  # card's list scope is within a single cell
  # so it means that both column_id and row_id must be the same
  # this long ugly line also makes sure that scope is fine when row or column is nil
  acts_as_list :scope => 'column_id #{column_id.nil? ? "IS NULL" : "= " + column_id.to_s} AND row_id #{row_id.nil? ? "IS NULL" : "= " + row_id.to_s}'
  acts_as_taggable

  def clone taskboard_id = taskboard_id, column_id = column_id, row_id = row_id
    Card.new(:name => name, :url => url, :issue_no => issue_no, :notes => notes, :position => position,
      :taskboard_id => taskboard_id, :column_id => column_id, :row_id => row_id)
  end

  def validate
    errors.add('Color is not valid!') if not color.match(/^#([abcdefABCDEF]|\d){6}$/)
  end

  def self.add_new taskboard_id, column_id, row_id, name = 'Empty!', issue_no = nil, url = nil
    card = Card.new(:taskboard_id => taskboard_id, :column_id => column_id, :row_id => row_id, :name => name,
      :issue_no => issue_no, :url => url)
    card.save!
    card.insert_at(1)
    card
  end
  
  # FIXME: why self is needed there?
  def move_to target_column_id, target_row_id, target_position
    target_column_id ||= column_id
    target_row_id ||= row_id
    if (column_id != target_column_id) or (row_id != target_row_id)
      # TODO check if new column is in same taskboard?
      remove_from_list
      self.column_id = target_column_id
      self.row_id = target_row_id
    end
    insert_at target_position
  end
  
  def color
     read_attribute(:color).nil? ? DEFAULT_COLOR : read_attribute(:color)
  end
  
  def short_name
    self.issue_no || truncate(self.name)
  end
  
  def hours_left
    self.hours.last.nil? ? 0 : self.hours.last.left
  end

  def hours_left_updated
    self.hours.last.nil? ? nil : self.hours.last.date
  end
  
  def burndown due_time = Time.now
    burndown = {}
    current_date = nil
    current_left = nil
    # iterate over every hour
    self.hours.sort_by {|hour| hour.date}.each { |hour|
      # fill the gap
      while not current_date.nil? and current_date + 1.day < hour.date
        current_date = current_date + 1.day
        burndown.store(current_date.strftime("%Y-%m-%d"), current_left)
      end
      current_date = hour.date.end_of_day
      current_left = hour.left
      burndown.store(current_date.strftime("%Y-%m-%d"), current_left)
    }
    # fill hours untill due time
    while not current_date.nil? and current_left > 0 and current_date < due_time
      current_date = current_date + 1.day
      burndown.store(current_date.strftime("%Y-%m-%d"), current_left)
    end
    return burndown
  end
  
  def update_hours left, added_at = Time.now
    hour = self.hours.sort{|x,y| y.date <=> x.date}.
      select {|h| h.date.beginning_of_day <= added_at && h.date.end_of_day >= added_at}[0]
    if not hour.nil?
      hour.left = left
      hour.save
    else
      self.hours << Hour.new(:left => left, :date => added_at )
      self.save
    end
  end
    
  def to_json options = {}
    options[:except] = [:created_at, :updated_at, :taskboard_id]
    options[:except] << :url if url.nil?
    options[:except] << :issue_no if issue_no.nil?
    options[:methods] = []
    options[:methods] << :tag_list
    options[:methods] << :hours_left
    options[:methods] << :hours_left_updated
    super(options)
  end

  # changes color to given one. should be in hex format i.e. #fc0fco
  # returns true if color was changed, false otherwise
  def change_color color
    self.color = color
    save
  end
  
end

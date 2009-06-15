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

class CardController < JuggernautSyncController
  
  include ApplicationHelper

  before_filter :authorize_read_only, :except => ["load_burndown"]

  def update_name
    @card = Card.find(params[:id].to_i)
    before = @card.name
    @card.name = params[:name]
    @card.save
    render :json => sync_update_card(@card, { :before => before, :after => @card.name, :message => "Card '#{before}' renamed to '#{@card.name}'"})
  end

  def update_notes
    @card = Card.find(params[:id].to_i)    
    before = @card.notes.nil? ? '' : @card.notes.gsub(/\n/, "\\n")
    @card.notes = params[:notes]
    @card.save
    render :json => sync_update_card(@card, { :before => before, :after => @card.notes.gsub(/\n/, "\\n"), :message => "Notes updated for '#{@card.name}'"})
  end

  def change_color
    card = Card.find(params[:id].to_i)
    if card.change_color(params[:color])
      render :json => sync_change_card_color(card)
    else
      send_error 'Invalid card new color!'
    end
  end
  
  def update_hours
     if params[:updated_at] == 'yesterday'
       updated_at = 1.day.ago       
     elsif params[:updated_at] == 'tomorrow'
       updated_at = 1.day.from_now
     else
       updated_at = Time.now
     end

    if params[:hours_left].to_i <= 0 and not params[:hours_left].strip == "0"
      send_error 'Hours left should be a positive number!'
    else
      @card = Card.find(params[:id].to_i)
      before = @card.hours_left
      @card.update_hours(params[:hours_left].to_i, updated_at)
      render :json => sync_update_card(@card, { :before => before, :after => @card.hours_left, :message => "Hours updated for '#{@card.name}'"})
    end
  end

  def add_tag
    @card = Card.find(params[:id].to_i)
    tags = params[:tags].split(',')
    tags.each { |tag| tag.strip! }
    before = @card.tag_list.to_s
    @card.tag_list.add(tags)
    @card.save
    render :json => sync_update_card(@card, { :before => before, :after => @card.tag_list.to_s, :message => "Tags added to '#{@card.name}'"})
  end
  
  def remove_tag
    @card = Card.find(params[:id].to_i)
    before = @card.tag_list.to_s
    @card.tag_list.remove(params[:tag])
    @card.save
    render :json => sync_update_card(@card, { :before => before, :after => @card.tag_list.to_s, :message => "Tags removed from '#{@card.name}'"})    
  end

  def load_burndown
    @card = Card.find(params[:id].to_i)
    render :text => burndown(@card)
  end

  private

  def send_error message = 'Error!'
    render :json => "{ status: 'error', message: '#{message}' }"
  end

end

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

class JuggernautSyncController < ApplicationController
  include ActionView::Helpers::TextHelper # to pluralize cards added
  
  # Taskboard actions
  
  def sync_rename_taskboard taskboard, params = {}
    options = { :message => "Taskboard renamed to '#{taskboard.name}'",
                :object_id => taskboard.id,
                :object_name => taskboard.name,
                :before => "", # should come in params
                :after => taskboard.name }
    options.update params
       
    report taskboard.id, 'renameTaskboard', options[:message], options
   
    send_via_juggernaut taskboard.id, 'renameTaskboard', taskboard.name.to_json, options[:message]
  end

  # Column actions
  
  def sync_column_action column, action, params = {}
    options = { :message => "Action '#{action}' called on a '#{column.name}' column",
                :object_id => column.id,
                :object_name => column.name,
                :before => "", # should come in params
                :after => "" }
    options.update params

    report column.taskboard_id, action, options[:message], options    
    send_via_juggernaut column.taskboard_id, action, column.to_json, options[:message]
  end
  
  def sync_add_column column, params = {}
    options = { :message => "Added a '#{column.name}' column" }.update params

    sync_column_action column, 'addColumn', options
  end

  def sync_rename_column column, params = {}
    options = { :message => "Column renamed to '#{column.name}'",
                :before => "", # should come in params
                :after => column.name }.update params

    sync_column_action column, 'renameColumn', options
  end

  def sync_move_column column, params = {}
    options = { :message => "Moved a '#{column.name}' column",
                :before => "", # should come in params
                :after => column.position }.update params
    
    sync_column_action column, 'moveColumn', options
  end

  def sync_delete_column column, params = {}
    options = { :message => "Deleted a '#{column.name}' column" }.update params
    sync_column_action column, 'deleteColumn', options
  end

  def sync_clean_column column, params = {}
    options = { :message => "Clean a '#{column.name}' column" }.update params
    sync_column_action column, 'cleanColumn', options
  end

  # Row actions
  def sync_row_action row, action, params = {}
    options = { :message => "Action '#{action}' called on a '#{row.name}' row",
                :object_id => row.id,
                :object_name => row.name,
                :before => "", # should come in params
                :after => "" }
    options.update params

    report row.taskboard_id, action, options[:message], options
    send_via_juggernaut row.taskboard_id, action, row.to_json, options[:message]
  end

  def sync_add_row row, params = {}
    options = { :message => "Added a row" }.update params
    sync_row_action row, 'addRow', options
  end

  def sync_delete_row row, params = {}
    options = { :message => "Deleted a row" }.update params
    sync_row_action row, 'deleteRow', options
  end

  def sync_clean_row row, params = {}
    options = { :message => "Clean a '#{row.name}' row" }.update params
    sync_column_action row, 'cleanRow', options
  end

  # Card actions
  
  def sync_card_action card, action, params = {}
    if card.is_a? Array
      taskboard_id = card.first.taskboard_id
      object_id    = card.map{ |c| c.id }.join(",")
      object_name  = card.map{ |c| "\"#{c.short_name}\"" }.join(",")
    else
      taskboard_id = card.taskboard_id
      object_id    = card.id
      object_name  = card.name
    end
        
    options = { :message => "Action '#{action}' called",
                :object_id => object_id,
                :object_name => object_name,
                :before => "",
                :after => "" }
    options.update params

    report taskboard_id, action, options[:message], options    
    send_via_juggernaut taskboard_id, action, card.to_json, options[:message]
  end
  
  def sync_add_cards cards, params = {}
    options = { :message => "#{pluralize cards.length, 'card'} added" }.update params
    
    sync_card_action cards, 'addCards', options
  end

  def sync_move_card card, params = {}
    options = { :message => "Moved a '#{card.name}' card",
                :before => "",
                :after => "#{card.position} @ #{card.column.name}"  }.update params
    
    sync_card_action card, 'moveCard', options
  end

  def sync_update_card_hours card, params = {}
    options = { :message => "Updated hours for a '#{card.name}' card",
                :before => "",
                :after => card.hours_left }.update params
    
    sync_card_action card, 'updateCardHours', options
  end

  def sync_change_card_color card, params = {}
    options = { :message => "Changed color of a '#{card.name}' card",
                :before => "",
                :after => card.color }.update params
    
    sync_card_action card, 'changeCardColor', options   
  end

  def sync_delete_card card, params = {}
    options = { :message => "Deleted a '#{card.name}' card", :before => "" }.update params
    
    sync_card_action card, 'deleteCard', options
  end

  def sync_update_card card, params = {}
    options = { :message => "Card '#{card.name}' updated", :before => "" }.update params
    
    sync_card_action card, 'updateCard', options    
  end
  
  private

  def generate_js_call function, parameter
    'sync.' + function + '(' + parameter + ')'
  end

  def send_via_juggernaut channel, function, json, message = "Juggernaut!!!"
    response = "{ status : 'success', message : #{message.to_json}, object : #{json} }"
    Juggernaut.send_to_channels( generate_js_call(function, response), [channel]);
    response
  end

  def report taskboard_id, action, message, params = {}
    insert_labels = true
    
    options = { :object_id => "", :object_name => "", :before => "", :after => "" }
    options.update params
    
    data = []
    data << "TIMESTAMP" if insert_labels
    data << Time.now.strftime("%Y%m%d%H%M%S")
    data << "USER_ID" if insert_labels
    data << session[:user_id]
    data << "USER_NAME" if insert_labels    
    data << (session[:user].nil? ? "" : session[:user].username)
    data << "ACTION" if insert_labels
    data << action
    data << "MSG" if insert_labels
    data << message
    data << "OBJECT_ID" if insert_labels    
    data << options[:object_id]
    data << "OBJECT_NAME" if insert_labels    
    data << options[:object_name]
    data << "BEFORE" if insert_labels    
    data << options[:before]
    data << "AFTER" if insert_labels    
    data << options[:after]
    
    report_logger(taskboard_id).info data.join("; ")
  end

end

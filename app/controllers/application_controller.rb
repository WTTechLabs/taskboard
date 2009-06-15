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

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  
  before_filter :authorize, :authorize_read_only

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'fba8a476189fb5d6dc6a7b9e889fb10f'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  def report_logger(id)
    @report_loggers = {} unless @report_loggers
    return @report_loggers[id] if @report_loggers[id]
    report_file_path = "#{RAILS_ROOT}/log/report/taskboard_#{id}.log"
    report_file = File.open(report_file_path, 'a') 
    report_file.sync = true
    @report_loggers[id] = Logger.new(report_file)
  end

  private
  def authorize
    session[:original_uri] = request.request_uri unless request.xhr?
    if session[:user_id].nil?
      redirect_to(:controller => 'login', :action => 'login')
    end
  end

  def authorize_read_only
    session[:original_uri] = request.request_uri unless request.xhr?
    unless session[:user_id].nil?
      unless session[:editor]
        flash[:notice] = "You do not have permission to do that!"
        redirect_to(:controller => 'taskboard', :action => 'index')
      end
    end
  end
end

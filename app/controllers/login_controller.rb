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

class LoginController < ApplicationController
  before_filter [:authorize, :authorize_read_only], :except => ["login","logout"]

  def add_user
    @user = User.new(params[:user])
    if request.post? and @user.save
      role = @user.editor? ? 'editor' : 'viewer'
      flash.now[:notice] = "Added new #{role} user #{@user.username}"
      @user = User.new
    end
  end
  
  def list_users
    @all_users = User.find(:all)
  end  
  
  def login
    login = params[:login]
    password = params[:password]

    if request.post?
      if(login.blank? || password.blank?)
        flash.now[:notice] = "Please fill in both user name and password!"
      else
        clear_session
        user = User.authenticate(login, password)
        if user
          session[:user_id] = user.id
          session[:user] = user
          session[:editor] = user.editor?
          uri = session[:original_uri]
          session[:original_uri] = nil
          redirect_to(uri || {:controller => 'taskboard', :action => "index"})
        else
          flash.now[:notice] = "Wrong user name or password!"
        end
      end
    end
  end

  def logout
    clear_session
    flash[:notice] = "You have logged out successfuly!";
    redirect_to :controller => "login", :action => "login"    
  end

  private

  def clear_session
    session[:user_id] = nil
    session[:user] = nil
    session[:editor] = false
  end
end

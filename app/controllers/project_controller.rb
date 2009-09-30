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

class ProjectController < ApplicationController

  before_filter :authorize_read_only, :except => ["index"]

  def index
    @projects = Project.find(:all, :order => "name")
  end

  def add
    project = Project.new
    project.name = params[:name].blank? ? Project::DEFAULT_NAME : params[:name]
    project.save!
    redirect_to :action => 'index'
  end

  def rename
    project = Project.find(params[:id].to_i)
    if not params[:name].blank?
      project.name = params[:name]
      project.save!
      render :json => { :status => 'success', :message => project.name }
    else
      render :json => { :status => 'error', :message => "Project's name cannot be empty" }
    end
  end

end

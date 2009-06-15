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

# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  # just wrap and produce js like data structure
  def burndown burndown_aware
    data = burndown_aware.burndown.sort.to_a.map{ |x| 
      # split string so we can get seconds from the epoch (as flot wants us to do)
      [ make_time( x[0] ) * 1000, x[1] ]
    }
    data.inspect
  end

  def make_time(time_in_string)
    time = time_in_string.split("-")
    Time.mktime(time[0], time[1], time[2], 0, 0, 0, 0).to_i
  end
  
end

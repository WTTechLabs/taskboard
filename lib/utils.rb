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

def time description = '', &block
  start = Time.now
  yield
  puts "execution time of #{description.empty? ? block.to_s : description}: #{Time.now - start}"
end

def get_file_as_string(filename)
  data = ''
    f = File.open(filename, "r") 
    f.each_line do |line|
      data += line
    end
  return data
end


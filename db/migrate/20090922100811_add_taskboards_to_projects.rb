require "migration_helpers"

class AddTaskboardsToProjects < ActiveRecord::Migration
  extend MigrationHelpers

  def self.up
    add_column :taskboards, :project_id, :integer
    add_foreign_key(:taskboards, :project_id, :projects)
    
    project = Project.create!(:name => "All taskboards")
    say_with_time 'Creating default project for all existing taskboards' do
      Taskboard.find(:all).each do |taskboard|
        taskboard.project = project
        taskboard.save!
      end
    end
  end

  def self.down
    remove_foreign_key(:taskboards, :project_id)
    remove_column :taskboards, :project_id
    
    Project.delete_all
  end
end


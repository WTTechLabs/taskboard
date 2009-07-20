require "migration_helpers"

class CreateRows < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    create_table :rows do |t|
      t.text :name, :null => false
      t.integer :position, :null => true 
      t.integer :taskboard_id, :null => false
      t.timestamps
    end
    
    add_foreign_key(:rows, :taskboard_id, :taskboards)
  end

  def self.down
    remove_foreign_key(:rows, :taskboard_id)
    
    drop_table :rows
  end
end

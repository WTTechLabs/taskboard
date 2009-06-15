require "migration_helpers"

class ForeignKeys < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    add_foreign_key(:cards, :taskboard_id, :taskboards)
    add_foreign_key(:cards, :column_id, :columns)
    add_foreign_key(:columns, :taskboard_id, :taskboards)
  end

  def self.down
    remove_foreign_key(:cards, :taskboard_id)
    remove_foreign_key(:cards, :column_id)
    remove_foreign_key(:columns, :taskboard_id)
  end
end

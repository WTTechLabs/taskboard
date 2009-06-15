class CreateCards < ActiveRecord::Migration
  def self.up
    create_table :cards do |t|
      t.text :name, :null => false
      t.text :notes, :null => true
      t.integer :taskboard_id
      t.integer :column_id
      t.integer :position, :null => true 
      t.string :issue_no, :null => true, :limit => 128
      t.string :color, :null => true, :limit => 128
      t.string :url, :null => true
      t.timestamps
    end
  end

  def self.down
    drop_table :cards
  end
end

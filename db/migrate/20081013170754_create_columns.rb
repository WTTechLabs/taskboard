class CreateColumns < ActiveRecord::Migration
  def self.up
    create_table :columns do |t|
      t.text :name, :null => false
      t.integer :position, :null => true 
      t.integer :taskboard_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :columns
  end
end

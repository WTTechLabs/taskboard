class CreateTaskboards < ActiveRecord::Migration
  def self.up
    create_table :taskboards do |t|
      t.text :name, :null => false 
      t.timestamps
    end
  end

  def self.down
    drop_table :taskboards
  end
end

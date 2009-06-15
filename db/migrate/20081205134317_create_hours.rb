class CreateHours < ActiveRecord::Migration
  def self.up
    create_table :hours do |t|
      t.datetime :date, :null => false
      t.integer :left, :null => false
      t.integer :card_id
      t.timestamps
    end
  end

  def self.down
    drop_table :hours
  end
end

require "migration_helpers"

class AddCardsToRows < ActiveRecord::Migration
  extend MigrationHelpers
  
  def self.up
    add_column :cards, :row_id, :integer
    add_foreign_key(:cards, :row_id, :rows)
    
    say_with_time 'Creating default rows for all existing taskboards' do
      Taskboard.find(:all).each do |taskboard|
        row = Row.create!(:name => "Default row", :taskboard_id => taskboard.id)
        taskboard.cards.each do |card|
          card.row_id = row.id;
          card.save!
        end
      end
    end
  end

  def self.down
    remove_foreign_key(:cards, :row_id)
    remove_column :cards, :row_id
    
    Row.delete_all
  end
end

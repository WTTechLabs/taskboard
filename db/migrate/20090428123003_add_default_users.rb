class AddDefaultUsers < ActiveRecord::Migration
  def self.up
    User.create!(:username => "taskboard", :password => "taskboard", :editor => true)
  end

  def self.down
    User.delete_all
  end
end

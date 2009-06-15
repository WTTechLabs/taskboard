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

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe CardController do
  integrate_views

  context "while dealing with name" do
  
    it "should allow update name for given card" do
      card = Card.new(:name => 'some card')
      Card.should_receive(:find).with(34).and_return(card)
      card.should_receive(:save)
      controller.should_receive(:sync_update_card).with(card, hash_including(:message, :before => 'some card', :after => 'new name')).and_return("{ status: 'success' }")
      
      post 'update_name', { :id => '34', :name => 'new name'}, {:user_id => 1, :editor => true}
      
      response.should be_success
      response.body.should include_text("status: 'success'")
      card.name.should eql('new name')
    end
  
  end
  
  context "while dealing with notes" do
  
    it "should allow updating new notes for given card" do
      card = Card.new(:notes => 'old notes')
      Card.should_receive(:find).with(77).and_return(card)
      card.should_receive(:save)
      controller.should_receive(:sync_update_card).with(card, hash_including(:message, :before => 'old notes', :after => '*this* is markdown message')).and_return("{ status: 'success' }")    
      
      post 'update_notes', { :id => '77', :notes => '*this* is markdown message' }, {:user_id => 1, :editor => true}
    
      response.should be_success
      response.body.should include_text("status: 'success'")
      card.notes.should eql('*this* is markdown message')
    end
  
  end
  
  context "while dealing with color" do

    it "should allow changing color" do
      card = Card.new(:taskboard_id => 23, :name => 'Card to change color')
      Card.should_receive(:find).with(12).and_return(card)
      card.should_receive(:change_color).with('#fc0fc0').and_return(true)
      controller.should_receive(:sync_change_card_color).with(card).and_return("{ status: 'success' }")
      post 'change_color', { :id => 12, :color => '#fc0fc0' }, {:user_id => 1, :editor => true}
      response.should be_success
      response.body.should include_text("status: 'success'")
    end
    
    it "should allow changing color and send appropriate error in case of fail" do
      card = Card.new
      Card.should_receive(:find).with(12).and_return(card)
      card.should_receive(:change_color).with('#fc0fc0').and_return(false)
      post 'change_color', { :id => 12, :color => '#fc0fc0' }, {:user_id => 1, :editor => true}
      response.should be_success
      response.body.should include_text("status: 'error'")
    end
    
  end
  
  context "while dealing with tags" do
  
    it "should allow adding single tag to cards" do 
      card = Card.new
      card.tag_list = ['existing one']
      
      Card.should_receive(:find).with(3).and_return(card)
      card.should_receive(:save)
      
      controller.should_receive(:sync_update_card).with(card, hash_including(:message, :before => "existing one", :after => "existing one, ala")).and_return("{ status: 'success' }")    
            
      post 'add_tag', { :id => '3', :tags => 'ala' }, {:user_id => 1, :editor => true}

      response.should be_success
      response.body.should include_text("status: 'success'")
      card.tag_list.size.should eql(2)
    end
    
    it "should allow adding multiple tags at once to cards" do 
      card = Card.new
      card.tag_list = ['existing one']
      
      Card.should_receive(:find).with(3).and_return(card)
      card.should_receive(:save)

      controller.should_receive(:sync_update_card).with(card, hash_including(:message, :before => "existing one", :after => "existing one, ala, ma, kota")).and_return("{ status: 'success' }")          
      post 'add_tag', { :id => '3', :tags => 'ala, ma,kota' }, {:user_id => 1, :editor => true}

      response.should be_success
      response.body.should include_text("status: 'success'")
      card.tag_list.size.should eql(4)
    end
    
    it "should allow removing tag from card" do
      card = Card.new
      card.tag_list = "ala, ma, kota"
      Card.should_receive(:find).with(5).and_return(card)
      card.should_receive(:save)

      controller.should_receive(:sync_update_card).with(card, hash_including(:message, :before => "ala, ma, kota", :after => "ala, kota")).and_return("{ status: 'success' }")                
      post 'remove_tag', { :id => '5', :tag => 'ma' }, {:user_id => 1, :editor => true}
      
      response.should be_success
      response.body.should include_text("status: 'success'")
      
      card.tag_list.size.should eql(2)

      card.tag_list.should_not include('ma')
      card.tag_list.should include('kota')
      card.tag_list.should include('ala')
    end
  
  end
  
  context "while dealing with hours" do
    
    it "should allow changes in hours left property" do
      card = Card.new
      Card.should_receive(:find).with(51).and_return(card)
      card.should_receive(:hours_left).twice().and_return(0, 12)
      card.should_receive(:update_hours).with(12, kind_of(Time))
      controller.should_receive(:sync_update_card).with(card, hash_including(:message, :before => 0, :after => 12)).and_return("{ status: 'success' }")                
      
      post 'update_hours', { :id => '51', :hours_left => '12' }, {:user_id => 1, :editor => true}

      response.should be_success
      response.body.should include_text("status: 'success'")
    end

    it "should allow changes in hours left for 'today'" do
      card = Card.new
      Card.should_receive(:find).with(51).and_return(card)
      card.should_receive(:hours_left).twice().and_return(0, 12)
      card.should_receive(:update_hours).with(12, date_around(Time.now))
      controller.should_receive(:sync_update_card).with(card, hash_including(:message, :before => 0, :after => 12)).and_return("{ status: 'success' }")                
      
      post 'update_hours', { :id => '51', :hours_left => '12', :updated_at => 'today' }, {:user_id => 1, :editor => true}

      response.should be_success
      response.body.should include_text("status: 'success'")
    end

    it "should allow changes in hours left for 'tomorrow'" do
      card = Card.new
      Card.should_receive(:find).with(51).and_return(card)
      card.should_receive(:hours_left).twice().and_return(0, 12)      
      card.should_receive(:update_hours).with(12, date_around(1.day.from_now))
      controller.should_receive(:sync_update_card).with(card, hash_including(:message, :before => 0, :after => 12)).and_return("{ status: 'success' }")                

      post 'update_hours', { :id => '51', :hours_left => '12', :updated_at => 'tomorrow' }, {:user_id => 1, :editor => true}

      response.should be_success
      response.body.should include_text("status: 'success'")
    end

    it "should allow changes in hours left for 'yesterday'" do
      card = Card.new
      Card.should_receive(:find).with(51).and_return(card)
      card.should_receive(:hours_left).twice().and_return(0, 12)      
      card.should_receive(:update_hours).with(12, date_around(1.day.ago))
      controller.should_receive(:sync_update_card).with(card, hash_including(:message, :before => 0, :after => 12)).and_return("{ status: 'success' }")                
      post 'update_hours', { :id => '51', :hours_left => '12', :updated_at => 'yesterday' }, {:user_id => 1, :editor => true}

      response.should be_success
      response.body.should include_text("status: 'success'")
    end
    
    it "should validate hours on save" do
      post 'update_hours', { :id => '13', :hours_left => 'miau' }, {:user_id => 1, :editor => true}
      response.should be_success
      response.body.should include_text("status: 'error'")

      post 'update_hours', { :id => '13', :hours_left => '-2' }
      response.should be_success
      response.body.should include_text("status: 'error'")
    end
  
  end
  
  context "while dealing with burndown" do
  
    it "should return burndown data" do
      card = Card.new

      Card.should_receive(:find).with(34).and_return(card)
      card.should_receive(:burndown).and_return({"2008-10-12" => "10"})

      post 'load_burndown', { :id => '34'}, {:user_id => 1, :editor => true}
      response.should be_success
      response.body.should include_text("1223762400000")
    end
  
  end
end



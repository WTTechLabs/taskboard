# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090707130233) do

  create_table "cards", :force => true do |t|
    t.text     "name",                        :null => false
    t.text     "notes"
    t.integer  "taskboard_id"
    t.integer  "column_id"
    t.integer  "position"
    t.string   "issue_no",     :limit => 128
    t.string   "color",        :limit => 128
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "row_id"
  end

  add_index "cards", ["column_id"], :name => "fk_cards_column_id"
  add_index "cards", ["row_id"], :name => "fk_cards_row_id"
  add_index "cards", ["taskboard_id"], :name => "fk_cards_taskboard_id"

  create_table "columns", :force => true do |t|
    t.text     "name",         :null => false
    t.integer  "position"
    t.integer  "taskboard_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "columns", ["taskboard_id"], :name => "fk_columns_taskboard_id"

  create_table "hours", :force => true do |t|
    t.datetime "date",       :null => false
    t.integer  "left",       :null => false
    t.integer  "card_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "rows", :force => true do |t|
    t.text     "name",         :null => false
    t.integer  "position"
    t.integer  "taskboard_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "rows", ["taskboard_id"], :name => "fk_rows_taskboard_id"

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "taskboards", :force => true do |t|
    t.text     "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username",        :null => false
    t.string   "hashed_password", :null => false
    t.string   "salt",            :null => false
    t.boolean  "editor"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end

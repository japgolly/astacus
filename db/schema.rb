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

ActiveRecord::Schema.define(:version => 20090625104203) do

  create_table "album_types", :force => true do |t|
    t.string "name", :null => false
  end

  create_table "albums", :force => true do |t|
    t.integer  "artist_id",     :null => false
    t.string   "name",          :null => false
    t.integer  "year"
    t.integer  "original_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artists", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audio_content", :force => true do |t|
    t.integer  "size",                      :null => false
    t.binary   "md5",        :limit => 255, :null => false
    t.binary   "sha2",       :limit => 255, :null => false
    t.string   "format",                    :null => false
    t.integer  "bitrate"
    t.float    "length"
    t.integer  "samplerate"
    t.boolean  "vbr"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "audio_content", ["size"], :name => "index_audio_content_on_size"

  create_table "audio_files", :force => true do |t|
    t.integer  "audio_content_id", :null => false
    t.text     "dirname",          :null => false
    t.string   "basename",         :null => false
    t.integer  "size",             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audio_tags", :force => true do |t|
    t.integer "audio_file_id",                     :null => false
    t.string  "format",        :limit => 8,        :null => false
    t.string  "version",       :limit => 10
    t.integer "offset",                            :null => false
    t.binary  "data",          :limit => 16777215, :null => false
  end

  create_table "cds", :force => true do |t|
    t.integer  "album_id",      :null => false
    t.integer  "album_type_id"
    t.string   "name"
    t.integer  "order_id",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tracks", :force => true do |t|
    t.integer  "cd_id",         :null => false
    t.integer  "tn"
    t.string   "name",          :null => false
    t.integer  "length"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "audio_file_id", :null => false
  end

end

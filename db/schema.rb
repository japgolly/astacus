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

ActiveRecord::Schema.define(:version => 20090715194431) do

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
    t.integer  "albumart_id"
  end

  add_index "albums", ["albumart_id"], :name => "index_albums_on_albumart_id"

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
    t.integer  "location_id",      :null => false
  end

  add_index "audio_files", ["location_id"], :name => "index_audio_files_on_location_id"

  create_table "audio_tags", :force => true do |t|
    t.integer "audio_file_id",                     :null => false
    t.string  "format",        :limit => 8,        :null => false
    t.string  "version",       :limit => 10
    t.integer "offset",                            :null => false
    t.binary  "data",          :limit => 16777215, :null => false
    t.integer "albumart_id"
  end

  add_index "audio_tags", ["albumart_id"], :name => "index_audio_tags_on_albumart_id"

  create_table "cds", :force => true do |t|
    t.integer  "album_id",      :null => false
    t.integer  "album_type_id"
    t.string   "name"
    t.integer  "order_id",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "images", :force => true do |t|
    t.integer  "size",                           :null => false
    t.binary   "data",       :limit => 16777215, :null => false
    t.string   "mimetype",                       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", :force => true do |t|
    t.text     "dir",        :null => false
    t.string   "label",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scanner_errors", :force => true do |t|
    t.integer  "location_id", :null => false
    t.text     "file",        :null => false
    t.text     "err_msg",     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scanner_errors", ["location_id"], :name => "index_scanner_errors_on_location_id"

  create_table "scanner_logs", :force => true do |t|
    t.integer  "location_id",                      :null => false
    t.datetime "started",                          :null => false
    t.datetime "ended"
    t.integer  "files_scanned"
    t.integer  "file_count"
    t.boolean  "active",                           :null => false
    t.boolean  "aborted",       :default => false, :null => false
  end

  add_index "scanner_logs", ["location_id", "active"], :name => "index_scanner_logs_on_location_id_and_active"

  create_table "tracks", :force => true do |t|
    t.integer  "cd_id",         :null => false
    t.integer  "tn"
    t.string   "name",          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "audio_file_id", :null => false
  end

  create_table "v_tracks", :id => false, :force => true do |t|
    t.integer "track_id",    :default => 0, :null => false
    t.string  "artist",                     :null => false
    t.integer "year"
    t.string  "album",                      :null => false
    t.string  "cd"
    t.integer "tn"
    t.string  "track",                      :null => false
    t.text    "dirname",                    :null => false
    t.string  "basename",                   :null => false
    t.integer "size",                       :null => false
    t.float   "length"
    t.integer "bitrate"
    t.integer "samplerate"
    t.boolean "vbr"
    t.integer "albumart_id"
  end

end

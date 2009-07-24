class IndexFkeyColumns < ActiveRecord::Migration
  def self.up
    add_index :albums, :artist_id
    add_index :audio_files, :audio_content_id
    add_index :audio_tags, :audio_file_id
    add_index :cds, [:album_id, :order_id]
    add_index :cds, :album_type_id
    add_index :tracks, :audio_file_id
  end

  def self.down
    remove_index :albums, :column => :artist_id
    remove_index :audio_files, :column => :audio_content_id
    remove_index :audio_tags, :column => :audio_file_id
    remove_index :cds, :column => [:album_id, :order_id]
    remove_index :cds, :column => :album_type_id
    remove_index :tracks, :column => :audio_file_id
  end
end

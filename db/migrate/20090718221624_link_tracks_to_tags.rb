class LinkTracksToTags < ActiveRecord::Migration
  def self.up
    create_table :audio_tags_tracks, :id => false do |t|
      t.integer :audio_tag_id, :null => false
      t.integer :track_id, :null => false
    end
    add_index :audio_tags_tracks, [:audio_tag_id, :track_id], :unique => true
    add_index :audio_tags_tracks, :track_id
  end

  def self.down
    drop_table :audio_tags_tracks
  end
end

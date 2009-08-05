class VariousArtistSupport < ActiveRecord::Migration
  def self.up
    add_column :tracks, :track_artist_id, :integer
    add_index :tracks, :track_artist_id
    add_column :discs, :va, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :discs, :va
    remove_column :tracks, :track_artist_id
  end
end

class TracksBelongToAudioFiles < ActiveRecord::Migration
  def self.up
    add_column :tracks, :audio_file_id, :integer, :null => false
  end

  def self.down
    remove_column :tracks, :audio_file_id
  end
end

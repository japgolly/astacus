class AudioFilesHaveLocations < ActiveRecord::Migration
  def self.up
    add_column :audio_files, :location_id, :integer, :null => false
    add_index :audio_files, :location_id
  end

  def self.down
    remove_column :audio_files, :location_id
  end
end

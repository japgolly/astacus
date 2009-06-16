class AudioFilesHaveSha2 < ActiveRecord::Migration
  def self.up
    add_column :audio_files, :sha2, :binary, :limit => 64
    #add_index :audio_files, :sha2, :limit => 16
    execute "CREATE INDEX index_audio_files_sha2 ON audio_files(sha2(16))"
  end

  def self.down
    remove_column :audio_files, :sha2
  end
end

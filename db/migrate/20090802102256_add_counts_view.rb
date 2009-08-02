class AddCountsView < ActiveRecord::Migration
  def self.up
    select= %w[
      audio_content
      audio_files
      audio_tags
      scanner_errors
      artists
      albums
      discs
      images
      tracks
      album_types
    ].map{|t| "(select count(*) from #{t}) #{t}"}.join(',')
    execute "create view v_counts as select #{select}"
  end

  def self.down
    execute "drop view v_counts;"
  end
end

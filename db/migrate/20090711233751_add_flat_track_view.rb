class AddFlatTrackView < ActiveRecord::Migration
  def self.up
    execute <<-EOS
      create view v_tracks as
      select t.id track_id, ar.name artist, al.year, al.name album, cd.name cd, t.tn, t.name track, dirname, basename, af.size, ac.length, bitrate, samplerate, vbr, al.albumart_id from tracks t, cds cd, albums al, artists ar, audio_files af, audio_content ac where t.cd_id=cd.id and cd.album_id=al.id and artist_id=ar.id and af.id=audio_file_id and ac.id=audio_content_id
      order by artist,year,album,cd,tn,track;
    EOS
  end

  def self.down
    execute "drop view v_tracks;"
  end
end

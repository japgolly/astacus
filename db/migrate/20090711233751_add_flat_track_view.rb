class AddFlatTrackView < ActiveRecord::Migration
  def self.up
    execute <<-EOS
      create view v_tracks as
      select t.id track_id, ar.name artist, al.year, al.name album, d.name disc, t.tn, t.name track, dirname, basename, af.size, ac.length, bitrate, samplerate, vbr, al.albumart_id
      from tracks t, discs d, albums al, artists ar, audio_files af, audio_content ac
      where t.disc_id=d.id and d.album_id=al.id and artist_id=ar.id and af.id=audio_file_id and ac.id=audio_content_id
      order by artist,year,album,disc,tn,track;
    EOS
  end

  def self.down
    execute "drop view v_tracks;"
  end
end

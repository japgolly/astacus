class StatsController < ApplicationController
  def index
    conn= ActiveRecord::Base.connection
    # conn.select_value(''),
    @stats= {
      :files                    => AudioFile.count,
      :filesize                 => AudioFile.sum(:size),
      :songs                    => -1, #xxxxxxxxx,
      :artists                  => Artist.count,
      :albums                   => Album.count,
      :cds                      => Cd.count,
      :tracks                   => Track.count,
      :length                   => AudioContent.sum(:length),
      :avg_albums_p_artist      => conn.select_value('select avg(c) from (select count(*) c from albums group by artist_id) a;'),
      :avg_tracks_p_artist      => conn.select_value('select avg(c) from (select count(*) c from tracks t inner join cds on cds.id=cd_id inner join albums al on al.id=album_id group by artist_id) a;'),
      :avg_tracks_p_cd          => conn.select_value('select avg(c) from (select count(*) c from tracks group by cd_id) a;'),
      :avg_length               => AudioContent.average(:length), # avg track length
      :avg_filesize             => AudioFile.average(:size), # avg file size
      :avg_bitrate              => AudioContent.average(:bitrate), # avg bitrate
#      :xxxxx                    => xxxxxxxxx, # albums with albumart
#      :xxxxx                    => xxxxxxxxx, # albums without albumart
#      :xxxxx                    => xxxxxxxxx, # bitrate buckets
#      :xxxxx                    => xxxxxxxxx, # length buckets
#      :xxxxx                    => xxxxxxxxx, # album year buckets
    }
  end
end

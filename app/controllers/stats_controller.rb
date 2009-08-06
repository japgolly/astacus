class StatsController < ApplicationController
  def index
    conn= ActiveRecord::Base.connection
    @stats= {
      :files                    => AudioFile.count,
      :filesize                 => AudioFile.sum(:size),
      :artists                  => Artist.count,
      :non_va_artists           => Album.count(:select => 'distinct artist_id', :joins => :discs, :conditions => 'discs.va=0'),
      :albums                   => Album.count,
      :non_va_albums            => Album.count(:select => 'distinct albums.id', :joins => :discs, :conditions => 'discs.va=0'),
      :multiple_disc_albums     => Album.count(:conditions => "discs_count>1"),
      :discs                    => Disc.count,
      :tracks                   => Track.count,
      :length                   => AudioContent.sum(:length),
      :avg_tracks_p_artist      => conn.select_value('select avg(c) from (select count(*) c from tracks t inner join discs on discs.id=disc_id inner join albums al on al.id=album_id group by artist_id) a;').to_f,
      :avg_bitrate              => AudioContent.average(:bitrate), # avg bitrate
#      :xxxxx                    => xxxxxxxxx, # discs with albumart
#      :xxxxx                    => xxxxxxxxx, # discs without albumart
#      :xxxxx                    => xxxxxxxxx, # bitrate buckets
#      :xxxxx                    => xxxxxxxxx, # length buckets
#      :xxxxx                    => xxxxxxxxx, # album year buckets
    }
    @stats[:avg_filesize]= safe_avg(:filesize,:files)
    @stats[:avg_length]= safe_avg(:length,:tracks)
    @stats[:avg_albums_p_artist]= safe_avg(:non_va_albums,:non_va_artists)
    @stats[:avg_tracks_p_disc]= safe_avg(:tracks,:discs)
  end

  private
    def safe_avg(total,count)
      count= @stats[count] if count.is_a?(Symbol)
      return 0 if count == 0
      total= @stats[total] if total.is_a?(Symbol)
      total.to_f / count
    end
end

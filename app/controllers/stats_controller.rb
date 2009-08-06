class StatsController < ApplicationController
  def index
    @stats= {
      :files                    => AudioFile.count,
      :filesize                 => AudioFile.sum(:size),
      :artists                  => Album.count(:select => 'distinct artist_id'),
      :albums                   => Album.count,
      :va_albums                => Album.count(:select => 'distinct albums.id', :joins => :discs, :conditions => 'discs.va=1'),
      :multiple_disc_albums     => Album.count(:conditions => "discs_count>1"),
      :discs                    => Disc.count,
      :tracks                   => Track.count,
      :length                   => AudioContent.sum(:length),
      :avg_bitrate              => AudioContent.average(:bitrate),
      :albums_without_albumart  => Album.count(:conditions => "albumart_id is null"),
    }
    @stats[:avg_filesize]= safe_avg(:filesize,:files)
    @stats[:avg_length]= safe_avg(:length,:tracks)
    @stats[:avg_albums_p_artist]= safe_avg(:albums,:artists)
    @stats[:avg_tracks_p_disc]= safe_avg(:tracks,:discs)
    @stats[:avg_tracks_p_artist]= safe_avg(:tracks,:artists)
    @stats[:albums_with_albumart]= @stats[:albums] - @stats[:albums_without_albumart]
  end

  private
    def safe_avg(total,count)
      count= @stats[count] if count.is_a?(Symbol)
      return 0 if count == 0
      total= @stats[total] if total.is_a?(Symbol)
      total.to_f / count
    end
end

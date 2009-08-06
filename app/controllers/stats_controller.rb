class StatsController < ApplicationController
  def index
    @sq= SearchQuery.tmp(params)
    if @sq.params.empty?
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
    elsif @sq.valid?
      # TODO Filtered stats be faster with a temp table
      @stats= {
        :files                    => filtered_album_stat(:count, :joins => {:discs => {:tracks => :audio_file}}),
        :filesize                 => filtered_album_stat(:sum, 'audio_files.size', :joins => {:discs => {:tracks => :audio_file}}).to_i,
        :artists                  => filtered_album_stat(:count, :select => 'distinct artist_id'),
        :albums                   => filtered_album_stat(:count),
        :va_albums                => filtered_album_stat(:count, :select => 'distinct albums.id', :joins => :discs, :conditions => 'discs.va=1'),
        :multiple_disc_albums     => filtered_album_stat(:count, :conditions => "discs_count>1"),
        :discs                    => filtered_album_stat(:count, :joins => :discs),
        :tracks                   => filtered_album_stat(:count, :joins => {:discs => :tracks}),
        :length                   => filtered_album_stat(:sum, 'audio_content.length', :joins => {:discs => {:tracks => {:audio_file => :audio_content}}}).to_f,
        :avg_bitrate              => filtered_album_stat(:average, 'audio_content.bitrate', :joins => {:discs => {:tracks => {:audio_file => :audio_content}}}).to_f,
        :albums_without_albumart  => filtered_album_stat(:count, :conditions => "albumart_id is null"),
      }
    else
      raise # TODO invalid sq in stats/index
    end

    # Calculate other stats based on data already loaded
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

    def filtered_album_stat(method, field=nil, options=nil)
      # Cater for optional field param
      if !options and field.is_a?(Hash)
        options= field
        field= nil
      end
      options||= {}

      # Apply filters
      joins= options.delete :joins
      conditions= options.delete :conditions
      options.reverse_merge! @sq.to_find_options
      SearchQuery.add_associations! options, :joins, joins if joins
      SearchQuery.add_query_conditions! options, *conditions if conditions

      # Get stat
      args= field ? [field] : []
      args<< options
      Album.send method, *args
    end
end

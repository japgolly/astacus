class StatsController < ApplicationController
  layout 'search'

  def index
    @search_query_form_url= stats_url
    albums_by_year_partition_size= 2

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
        :albums_by_year           => Album.count(:group => "year-year%#{albums_by_year_partition_size}"),
        :albums_by_decade         => Album.count(:group => "year-year%10"),
      }
    elsif @sq.valid?
      # Use the sq to create a table table of album ids
      conn= Album.connection
      conn.execute "DROP TEMPORARY TABLE IF EXISTS #{TMP_TABLE_NAME};"
      sql= Album.get_raw_sql @sq.to_find_options.merge(:select => 'albums.id')
      conn.execute "CREATE TEMPORARY TABLE #{TMP_TABLE_NAME}(UNIQUE(id)) ENGINE MEMORY IGNORE AS #{sql}"

      # Get stats using temp table
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
        :albums_by_year           => filtered_album_stat(:count, :group => "year-year%#{albums_by_year_partition_size}"),
        :albums_by_decade         => filtered_album_stat(:count, :group => "year-year%10"),
      }
      conn.execute "DROP TEMPORARY TABLE #{TMP_TABLE_NAME};"
    else
      raise # TODO invalid sq in stats/index
    end
    # TODO test stats/index with no results

    # Calculate other stats based on data already loaded
    @stats[:avg_filesize]= safe_avg(:filesize,:files)
    @stats[:avg_length]= safe_avg(:length,:tracks)
    @stats[:avg_albums_p_artist]= safe_avg(:albums,:artists)
    @stats[:avg_tracks_p_disc]= safe_avg(:tracks,:discs)
    @stats[:avg_tracks_p_artist]= safe_avg(:tracks,:artists)
    @stats[:albums_with_albumart]= @stats[:albums] - @stats[:albums_without_albumart]

    # Process graph stats
    process_graph_stat! :albums_by_year, albums_by_year_partition_size
    process_graph_stat! :albums_by_decade, 10
  end

  private
    TMP_TABLE_NAME= "tmp_album_ids".freeze
    TMP_TABLE_JOIN_SQL= "INNER JOIN #{TMP_TABLE_NAME} ON #{TMP_TABLE_NAME}.id = albums.id".freeze

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
      options[:joins]= if options[:joins]
        jsql= Album.get_raw_sql(:joins => options[:joins]).sub(/^.+?(?=INNER JOIN)/,'')
        "#{TMP_TABLE_JOIN_SQL} #{jsql}"
      else
        TMP_TABLE_JOIN_SQL
      end

      # Get stat
      args= field ? [field] : []
      args<< options
      Album.send method, *args
    end

    # Data returned by a count(:group=>x) needs a small amount of preprocessing
    # before it is ready for rendering.
    def process_graph_stat!(key, step)
      o= {}
      @stats[key].each{|k,v| o[k ? k.to_i : k]= v}
      keys= o.keys.reject(&:nil?)
      o[:max_value]= o.values.max
      o[:min]= keys.min
      o[:max]= keys.max
      o[:step]= step
      @stats[key]= o
    end
end

class SearchController < ApplicationController
  def search
    # Default options
    options= {
      :page => params[:page] || 1,
      :per_page => 10,
      :select => 'distinct albums.*',
      :include => [:artist, {:discs => {:tracks => {:audio_file => :audio_content}}}],
      :readonly => true,
    }

    # Filter options
    filter_options= {}
    if params[:artist]
      add_to_array_param filter_options, :joins, :artist
      add_conditions filter_options, 'upper(artists.name) LIKE upper(?)', "%#{params[:artist]}%"
    end
    if params[:album]
      add_conditions filter_options, 'upper(albums.name) LIKE upper(?)', "%#{params[:album]}%"
    end
    if params[:track]
      add_to_array_param filter_options, :joins, {:discs => :tracks}
      add_conditions filter_options, 'upper(tracks.name) LIKE upper(?)', "%#{params[:track]}%"
    end
    options.deep_merge! filter_options

    # Sort options
    add_to_array_param options, :joins, :artist
    options.merge! :order => 'artists.name, albums.year, albums.name'

    # Get results
    @albums= Album.paginate(options)
  end

  private
    def add_to_array_param(hash, key, value)
      if hash[key]
        hash[key]= [hash[key]] unless hash[key].is_a?(Array)
        hash[key]<< value unless hash[key].include?(value)
      else
        hash[key]= [value]
      end
    end

    def add_conditions(hash, sql, *params)
      if hash[:conditions]
        hash[:conditions][0]+= " AND #{sql}"
        hash[:conditions].concat params
      else
        hash[:conditions]= [sql, *params]
      end
    end
end

class SearchController < ApplicationController
  def search
    # Default options
    options= {
      :page => params[:page] || 1,
      :per_page => 10,
      :include => [:artist, {:discs => {:tracks => {:audio_file => :audio_content}}}],
      :readonly => true,
    }

    # Filter options
    filter_options= {}
    if params[:artist]
      add_to_array_param filter_options, :joins, :artist
      filter_options[:conditions]= ['upper(artists.name) LIKE upper(?)', "%#{params[:artist]}%"]
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

end

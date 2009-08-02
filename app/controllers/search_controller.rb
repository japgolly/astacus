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
    sq= SearchQuery.new(:params => params)
    options.deep_merge! sq.to_find_options

    # Sort options
    SearchQuery.add_associations! options, :joins, :artist
    options.merge! :order => 'artists.name, albums.year, albums.name'

    # Get results
    @albums= Album.paginate(options)
  end
end

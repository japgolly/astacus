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
    query_params= params.symbolize_keys
    query_params.delete :page
    query_params.delete :action
    query_params.delete :controller
    sq= SearchQuery.new(:params => query_params)
    options.deep_merge! sq.to_find_options

    # Sort options
    sq.add_associations! options, :joins, :artist
    options.merge! :order => 'artists.name, albums.year, albums.name'

    # Get results
    @albums= Album.paginate(options)
  end
end

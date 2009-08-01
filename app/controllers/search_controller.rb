class SearchController < ApplicationController
  def search
    @albums= Album.paginate({
      :page => params[:page] || 1,
      :per_page => 10,
      :joins => :artist,
      :include => [:artist, {:discs => {:tracks => {:audio_file => :audio_content}}}],
      :readonly => true,
      :order => 'artists.name, albums.year, albums.name',
#      :conditions => 'albums.id in(37,38)',
    })
  end

end

class FileController < ApplicationController
  layout nil
  # caches_page :image # doesn't seem to respect mimetype, will test later

  def audio
    id= params[:id]
    @af= AudioFile.find(id) rescue nil if id
    if @af.nil?
      render :nothing => true, :status => 404
    elsif !@af.exists?
      render :action => "audio_file_not_found", :status => 417
    else
      send_file @af.filename, :type => @af.mimetype
    end
  end

  def image
    id= params[:id]
    img= Image.find(id) rescue nil if id
    if img
      send_data img.data,
        :filename => "#{id}.#{img.file_extention}",
        :type => img.mimetype,
        :disposition => 'inline'
    else
      render :nothing => true, :status => 404
    end
  end
end

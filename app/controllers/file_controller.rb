class FileController < ApplicationController
  # caches_page :image # doesn't seem to respect mimetype, will test later

  def audio
    id= params[:id]
    af= AudioFile.find(id) rescue nil if id
    if af.nil?
      render :nothing => true, :status => 404
    elsif !af.exists?
      render :text => "#{af.filename} doesn't exist.", :status => 417
    else
      send_file af.filename, :type => af.mimetype
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

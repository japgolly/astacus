class ImageController < ApplicationController
  caches_page :view

  def view
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

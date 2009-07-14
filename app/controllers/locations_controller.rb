class LocationsController < ApplicationController
  def index
    @locations= Location.all
  end

  def create
    @location= Location.new(params[:location])
    @location.save
  end
end

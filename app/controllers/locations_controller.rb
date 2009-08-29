class LocationsController < ApplicationController
  def index
    @locations= Location.all
  end

  def create
    @location= Location.new(params[:location])
    @location.save
  end

  def show
    @location= Location.find(params[:id])
  end

  def edit
    @location= Location.find(params[:id])
  end

  def update
    @location= Location.find(params[:id])
    @location.label= params[:location][:label]
    @location.save
  end

  # TODO Test start_scan
  def start_scan
    @location= Location.find(params[:id])
    if @location.exists?
      full= (params[:full] == '1')
      @location.scan_async(full)
      sleep 3
    end
    render :action => 'show'
  end
end

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
#      Thread.start {Astacus::Scanner.new.scan(@location)}
#      sleep 1
      Astacus::Scanner.new.scan(@location) # TODO Fix start_scan runs in the foreground...
    end
    render :action => 'show'
  end
end

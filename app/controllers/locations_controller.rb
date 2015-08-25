class LocationsController < ApplicationController
  def index
    @locations = Location.all
  end

  def show
    @location = Location.find(params[:id])
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new
    @location.user_id = params[:user_id]
    @location.Longitude = params[:Longitude]
    @location.Latitude = params[:Latitude]
    @location.Address = params[:Address]
    @location.Name = params[:Name]

    if @location.save
      redirect_to "/locations", :notice => "Location created successfully."
    else
      render 'new'
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    @location = Location.find(params[:id])

    @location.user_id = params[:user_id]
    @location.Longitude = params[:Longitude]
    @location.Latitude = params[:Latitude]
    @location.Address = params[:Address]
    @location.Name = params[:Name]

    if @location.save
      redirect_to "/locations", :notice => "Location updated successfully."
    else
      render 'edit'
    end
  end

  def destroy
    @location = Location.find(params[:id])

    @location.destroy

    redirect_to "/locations", :notice => "Location deleted."
  end
end

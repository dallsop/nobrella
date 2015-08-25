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
    # clean address
    @street_address = params[:Address]
    url_safe_street_address = URI.encode(@street_address)

    # get lat & long data
    loc_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{url_safe_street_address}"
    parsed_loc_data = JSON.parse(open(loc_url).read)
    latitude = parsed_loc_data["results"][0]["geometry"]["location"]["lat"]
    longitude = parsed_loc_data["results"][0]["geometry"]["location"]["lng"]

    @location.user_id = params[:user_id]
    @location.Longitude = longitude
    @location.Latitude = latitude
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

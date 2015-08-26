require 'open-uri'

class LocationsController < ApplicationController
  def index
    @locations = Location.where({user_id: current_user.id}).order("Name ASC")
  end

  def new
    @location = Location.new
  end

  def create
    # clean address
    @street_address = params[:Address]
    url_safe_street_address = URI.encode(@street_address)

    # connect to Google Maps API
    loc_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{url_safe_street_address}"
    parsed_loc_data = JSON.parse(open(loc_url).read)

    # flag for accurate data
    if parsed_loc_data["status"] != "ZERO_RESULTS"

      # get lat, long, and clean address
      latitude = parsed_loc_data["results"][0]["geometry"]["location"]["lat"]
      longitude = parsed_loc_data["results"][0]["geometry"]["location"]["lng"]
      clean_address = parsed_loc_data["results"][0]["formatted_address"].to_s

      # assign all values to new db row
      @location = Location.new
      @location.user_id = current_user.id
      @location.Name = params[:Name]
      @location.Longitude = longitude
      @location.Latitude = latitude
      @location.Address = clean_address

      # save new row and redirect to locations page
      @location.save
      redirect_to "/locations", notice: "Location created successfully."
    else
      render 'new', notice: "Invalid location."
    end
  end


  def edit
    @location = Location.find(params[:id])
  end

  def update
    # clean address
    @street_address = params[:Address]
    url_safe_street_address = URI.encode(@street_address)

    # connect to Google Maps API
    loc_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{url_safe_street_address}"
    parsed_loc_data = JSON.parse(open(loc_url).read)

    # flag for accurate data
    if parsed_loc_data["status"] != "ZERO_RESULTS"

      # get lat, long, and clean address
      latitude = parsed_loc_data["results"][0]["geometry"]["location"]["lat"]
      longitude = parsed_loc_data["results"][0]["geometry"]["location"]["lng"]
      clean_address = parsed_loc_data["results"][0]["formatted_address"]

      # assign all values to new db row
      @location = Location.find(params[:id])
      @location.user_id = params[:user_id]
      @location.Name = params[:Name]
      @location.Longitude = longitude
      @location.Latitude = latitude
      @location.Address = clean_address

      # save new row and redirect to locations page
      @location.save
      redirect_to "/locations", notice: "Location updated successfully."
    else
      render 'edit', notice: "Invalid location."
    end
  end

  def destroy
    @location = Location.find(params[:id])

    @location.destroy

    redirect_to "/locations", :notice => "Location deleted."
  end

end

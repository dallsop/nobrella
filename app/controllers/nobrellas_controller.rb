require 'open-uri'

class NobrellasController < ApplicationController
  def street_to_weather_form
    # Nothing to do here.
    render("street_to_weather_form.html.erb")
  end

  def street_to_weather


    # set up forecast data
    forecast_url = "https://api.forecast.io/forecast/17593b21cc409b60b31ec90b6a5d8d38/#{latitude},#{longitude}"
    parsed_forecast_data = JSON.parse(open(forecast_url).read)

    #### assign weather data to variables ####
    @current_temperature = parsed_forecast_data["currently"]["temperature"]

    @current_summary = parsed_forecast_data["currently"]["summary"]

    # flag for minutely==nilclass because dark sky forecast doesn't return minutely information for all locations
    parsed_forecast_data["minutely"].nil? ?
        @summary_of_next_sixty_minutes = "No information available." :
        @summary_of_next_sixty_minutes = parsed_forecast_data["minutely"]["summary"]

    @summary_of_next_several_hours = parsed_forecast_data["hourly"]["summary"]

    @summary_of_next_several_days = parsed_forecast_data["daily"]["summary"]

    render("street_to_weather.html.erb")
  end



end
require 'open-uri'

class NobrellasController < ApplicationController

  def index
    # find relevant events (next 16 hours [960 minutes])
    now_in_minutes = (Time.now.hour * 60) + (Time.now.min)
    end_in_minutes = now_in_minutes + 960
    today_weekday = Date.today.strftime("%A")
    if end_in_minutes <= 1440 # 16 hours from now is same day
      key_events = Event.where("user_id = ? AND Day = ? AND Start BETWEEN ? AND ?", current_user.id, today_weekday, now_in_minutes, end_in_minutes).order("Start ASC")
    else # 16 hours from now is next day
      tomorrow_weekday = Date.tomorrow.strftime("%A")
      key_events = Event.where("user_id = ? AND ((Day = ? AND Start >= ?) OR (Day = ? AND Start <= ?))", current_user.id, today_weekday, now_in_minutes, tomorrow_weekday, end_in_minutes - 1440).order("Start ASC")
    end

    if key_events.count > 0 # must be at least one event to check for
      weather_info_array = Array.new # array to log weather data: time, summary, temperature, precipitation %
      now_unix_time = Date.today.to_time.to_i # time in seconds since 1/1/1970 to match forecast.io API
      key_events.each do |e|
        # API input variables
        latitude = e.location.Latitude
        longitude = e.location.Longitude
        target_time = now_unix_time + (60 * (e.Start - now_in_minutes))
        target_time += 86400 if e.Day == tomorrow_weekday # add one day's time in seconds if day is tomorrow
        # get weather data
        forecast_url = "https://api.forecast.io/forecast/17593b21cc409b60b31ec90b6a5d8d38/#{latitude},#{longitude},#{target_time}"
        parsed_forecast_data = JSON.parse(open(forecast_url).read)
        # pull out key values
        weather_summary = parsed_forecast_data["currently"]["icon"]
        temperature = parsed_forecast_data["currently"]["temperature"]
        precipitation = parsed_forecast_data["currently"]["precipProbability"]
        # load values to array
        weather_info_array.push([target_time, weather_summary, temperature, precipitation])
      end

      ##### logic to create weather messages #####

      @nobrella_advice = ""
      @nobrella_detail = ""

      # things to take
      take_jacket = FALSE
      take_sunglasses = FALSE
      take_coat = FALSE
      take_umbrella = FALSE

      # key conditions (0 = n/a, 1 = later, 2 = soon, 3 = now), always favors earlier (larger values)
      rain = [FALSE, 0]
      snow = [FALSE, 0]
      sleet = [FALSE, 0]
      sunny = [FALSE, 0]
      cold = [FALSE, 0]
      chilly = [FALSE, 0]

      #loop through weather array
      weather_info_array.each do |w|
        # TEMPERATURE CHECK #
        if w[2] < 50
          take_coat = TRUE
          cold[0] = TRUE
          cold[1] = [cold[1],get_time_group(now_unix_time,w[0])].max
        elsif w[2] < 70
          take_jacket = TRUE
          chilly[0] = TRUE
          chilly[1] = [chilly[1],get_time_group(now_unix_time,w[0])].max
        end
        # CONDITION CHECKS #
        # rain
        if w[1] == "rain"
          take_umbrella = TRUE
          rain[0] = TRUE
          rain[1] = [rain[1],get_time_group(now_unix_time,w[0])].max
        end
        # snow
        if w[1] == "snow"
          take_coat = TRUE
          snow[0] = TRUE
          snow[1] = [snow[1],get_time_group(now_unix_time,w[0])].max
        end
        # sleet
        if w[1] == "sleet"
          take_umbrella = TRUE
          take_coat = TRUE
          sleet[0] = TRUE
          sleet[1] = [sleet[1],get_time_group(now_unix_time,w[0])].max
        end
        # sun
        if w[1] == "clear-day"
          take_sunglasses = TRUE
          sunny[0] = TRUE
          sunny[1] = [sunny[1],get_time_group(now_unix_time,w[0])].max
        end
      end

      # make lists
      things = Array.new
      things.push("a coat") if take_coat == TRUE
      things.push("an umbrella") if take_umbrella == TRUE
      things.push("sunglasses") if take_sunglasses == TRUE
      if take_jacket == TRUE and take_coat == FALSE #coat and jacket mutually exclusive
        things.push("a jacket")
      end

      conditions = Array.new
      conditions.push(["rain", rain[1]]) if rain[0] == TRUE
      conditions.push(["snow", snow[1]]) if snow[0] == TRUE
      conditions.push(["sleet", sleet[1]]) if sleet[0] == TRUE
      conditions.push(["sunny", sunny[1]]) if sunny[0] == TRUE
      conditions.push(["cold", cold[1]]) if cold[0] == TRUE
      conditions.push(["chilly", chilly[1]]) if chilly[0] == TRUE

      


    else

    end


  end

  def get_time_group(now, target)
    difference_in_minutes = (target - now) / 60
    case difference_in_minutes
      when 0..60
        return 3
      when 60..180
        return 2
      else
        return 1
    end
  end

end
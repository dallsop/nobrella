require 'open-uri'

class NobrellasController < ApplicationController

  def index
    # find relevant events (next 16 hours [960 minutes])
    now_in_minutes = (DateTime.now.change(offset: "-0500").hour * 60) + (DateTime.now.change(offset: "-0500").min)
    end_in_minutes = now_in_minutes + 960
    today_weekday = DateTime.now.change(offset: "-0500").strftime("%A")
    if end_in_minutes <= 1440 # 16 hours from now is same day
      key_events = Event.where("user_id = ? AND day = ? AND start BETWEEN ? AND ?", current_user.id, today_weekday, now_in_minutes, end_in_minutes).order("start ASC")
    else # 16 hours from now is next day
      tomorrow_weekday = DateTime.now.change(offset: "-0500").tomorrow.strftime("%A")
      key_events = Event.where("user_id = ? AND ((day = ? AND start >= ?) OR (day = ? AND start <= ?))", current_user.id, today_weekday, now_in_minutes, tomorrow_weekday, end_in_minutes - 1440).order("start ASC")
    end

    if key_events.count > 0 # must be at least one event to check for
      weather_info_array = Array.new # array to log weather data: time, summary, temperature, precipitation %
      now_unix_time = DateTime.now.change(offset: "-0500").to_time.to_i # time in seconds since 1/1/1970 to match forecast.io API
      key_events.each do |e|
        # API input variables
        @latitude = e.location.latitude
        @longitude = e.location.longitude
        target_time = now_unix_time + (60 * (e.start - now_in_minutes))
        target_time += 86400 if e.day == tomorrow_weekday # add one day's time in seconds if day is tomorrow
        # get weather data
        forecast_url = "https://api.forecast.io/forecast/17593b21cc409b60b31ec90b6a5d8d38/#{@latitude},#{@longitude},#{target_time}"
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
          cold[1] = [cold[1], get_time_group(now_unix_time, w[0])].max
        elsif w[2] < 70
          take_jacket = TRUE
          chilly[0] = TRUE
          chilly[1] = [chilly[1], get_time_group(now_unix_time, w[0])].max
        end
        # CONDITION CHECKS #
        # rain
        if w[1] == "rain"
          take_umbrella = TRUE
          rain[0] = TRUE
          rain[1] = [rain[1], get_time_group(now_unix_time, w[0])].max
        end
        # snow
        if w[1] == "snow"
          take_coat = TRUE
          snow[0] = TRUE
          snow[1] = [snow[1], get_time_group(now_unix_time, w[0])].max
        end
        # sleet
        if w[1] == "sleet"
          take_umbrella = TRUE
          take_coat = TRUE
          sleet[0] = TRUE
          sleet[1] = [sleet[1], get_time_group(now_unix_time, w[0])].max
        end
        # sun
        if w[1] == "clear-day"
          take_sunglasses = TRUE
          sunny[0] = TRUE
          sunny[1] = [sunny[1], get_time_group(now_unix_time, w[0])].max
        end
      end

      # make lists
      things = Array.new
      things.push("a coat") if take_coat == TRUE
      things.push("an umbrella") if take_umbrella == TRUE
      things.push("some sunglasses") if take_sunglasses == TRUE
      if take_jacket == TRUE and take_coat == FALSE #coat and jacket mutually exclusive
        things.push("a jacket")
      end

      conditions = Array.new # conditions sorted deliberately to have at most one for each time period
      conditions.push(["a little chilly", chilly[1]]) if chilly[0] == TRUE
      conditions.push(["pretty cold", cold[1]]) if cold[0] == TRUE
      conditions.push(["nice and sunny", sunny[1]]) if sunny[0] == TRUE
      conditions.push(["rain", rain[1]]) if rain[0] == TRUE
      conditions.push(["snow", snow[1]]) if snow[0] == TRUE
      conditions.push(["sleet", sleet[1]]) if sleet[0] == TRUE

      # segregate conditions by time
      conditions_later = FALSE
      conditions_soon = FALSE
      conditions_now = FALSE
      the_condition_later = ""
      the_condition_soon = ""
      the_condition_now = ""
      conditions.each do |c|
        if c[1] == 1
          conditions_later = TRUE
          if c[0] == "a little chilly" or c[0] == "pretty cold" or c[0] == "nice and sunny"
            the_condition_later = "be #{c[0]}"
          else
            the_condition_later = c[0]
          end
        elsif c[1] == 2
          conditions_soon = TRUE
          if c[0] == "a little chilly" or c[0] == "pretty cold" or c[0] == "nice and sunny"
            the_condition_soon = "be #{c[0]}"
          else
            the_condition_soon = c[0]
          end
        elsif c[1] == 3
          conditions_now = TRUE
          if c[0] == "rain" or c[0] == "sleet" or c[0] == "snow"
            the_condition_now = c[0] + "ing"
          else
            the_condition_now = c[0]
          end
        end
      end

      # write advice message
      case things.count
        when 0
          @nobrella_advice = "You don't need anything!"
          @nobrella_detail = "It's pretty nice out."
          @latitude = key_events[0].location.latitude
          @longitude = key_events[0].location.longitude
        when 1
          @nobrella_advice = "Take #{things[0]}."
        when 2
          @nobrella_advice = "Take #{things[0]} and #{things[1]}."
        when 3
          @nobrella_advice = "Take #{things[0]}, #{things[1]}, and #{things[2]}."
        else
      end

      # write detail message
      if conditions_now == TRUE
        @nobrella_detail = "It's #{the_condition_now} out now"
        if conditions_soon == TRUE
          if conditions_later == TRUE
            @nobrella_detail += ", it's gonna #{the_condition_soon} soon, and it'll #{the_condition_later} later."
          else
            @nobrella_detail += " and it's gonna #{the_condition_soon} soon."
          end
        else
          if conditions_later == TRUE
            @nobrella_detail += " and it'll #{the_condition_later} later."
          else
            @nobrella_detail += "."
          end
        end
      elsif conditions_soon == TRUE
        @nobrella_detail = "It's gonna #{the_condition_soon} soon"
        if conditions_later == TRUE
          @nobrella_detail += " and it'll #{the_condition_later} later."
        else
          @nobrella_detail += "."
        end
      elsif conditions_later == TRUE
        @nobrella_detail = "It'll #{the_condition_later} later."
      end
    else
      @nobrella_advice = "No plans coming up."
      all_user_locations = Location.where({user_id: current_user.id})
      if all_user_locations.count > 0 # if user has any locations set up
        sample_location = all_user_locations.sample
        @latitude = sample_location.latitude
        @longitude = sample_location.longitude
        forecast_url = "https://api.forecast.io/forecast/17593b21cc409b60b31ec90b6a5d8d38/#{@latitude},#{@longitude}"
        parsed_forecast_data = JSON.parse(open(forecast_url).read)
        current_summary = parsed_forecast_data["currently"]["summary"].downcase
        @nobrella_detail = "But it's #{current_summary} out if you were thinking about leaving."
      else
        @nobrella_detail = "N/A"
      end
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
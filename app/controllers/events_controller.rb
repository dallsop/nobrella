class EventsController < ApplicationController
  def index
    @days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @events = Event.where({user_id: current_user.id}).order("Start ASC")
  end

  def new
    @days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @input_day = params[:day]
    @event = Event.new
  end

  def create
    if Chronic.parse(params[:Start]) == nil
      redirect_to "/events/new/#{params[:Day]}", alert: "Time not valid."
    else
      @event = Event.new
      start_time_in_minutes = (Chronic.parse(params[:Start]).strftime('%H').to_i * 60) + (Chronic.parse(params[:Start]).strftime('%M').to_i)
      @event.Start = start_time_in_minutes
      @event.Day = params[:Day]
      @event.location_id = params[:location_id]
      @event.user_id = current_user.id

      if @event.save
        redirect_to "/events"
      else
        render 'new'
      end
    end
  end

  def duplicate_right
    event_to_duplicate = Event.find(params[:id])
    @event = Event.new
    @event.Start = event_to_duplicate.Start
    @event.location_id = event_to_duplicate.location_id
    @event.user_id = event_to_duplicate.user_id
    days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    current_day_index = days.index(event_to_duplicate.Day)
    current_day_index == 6 ? new_day_index = 0 : new_day_index = current_day_index + 1 # ternary to flag if day is sunday
    @event.Day = days[new_day_index]
    if @event.save
      redirect_to "/events"
    else
      redirect_to "/events", :alert => "Couldn't copy."
    end
  end

  def duplicate_left
    event_to_duplicate = Event.find(params[:id])
    @event = Event.new
    @event.Start = event_to_duplicate.Start
    @event.location_id = event_to_duplicate.location_id
    @event.user_id = event_to_duplicate.user_id
    days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    current_day_index = days.index(event_to_duplicate.Day)
    current_day_index == 0 ? new_day_index = 6 : new_day_index = current_day_index - 1 # ternary to flag if day is monday
    @event.Day = days[new_day_index]
    if @event.save
      redirect_to "/events"
    else
      redirect_to "/events", :alert => "Couldn't copy."
    end
  end

  def edit

    @event = Event.find(params[:id])
  end

  def update
    @days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @event = Event.find(params[:id])
    start_time_in_minutes = (Chronic.parse(params[:Start]).strftime('%H').to_i * 60) + (Chronic.parse(params[:Start]).strftime('%M').to_i)
    @event.Start = start_time_in_minutes
    @event.Day = params[:Day]
    @event.location_id = params[:location_id]

    if @event.save
      redirect_to "/events"
    else
      render 'edit'
    end
  end

  def destroy
    @event = Event.find(params[:id])

    @event.destroy

    redirect_to "/events"
  end
end

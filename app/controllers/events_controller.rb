class EventsController < ApplicationController
  def index
    @days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @events = Event.where({user_id: current_user.id}).order("Start ASC")
  end

  def new
    @days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    @event = Event.new
  end

  def create
    @event = Event.new
    @event.Start = params[:Start]
    @event.Day = params[:Day]
    @event.location_id = params[:location_id]
    @event.user_id = current_user.id

    if @event.save
      redirect_to "/events"
    else
      render 'new'
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

    @event.Start = params[:Start]
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

    redirect_to "/events", :notice => "Event deleted."
  end
end

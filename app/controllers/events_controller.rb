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
      redirect_to "/events", :notice => "Successfully added."
    else
      render 'new'
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
      redirect_to "/events", :notice => "Successfully updated."
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

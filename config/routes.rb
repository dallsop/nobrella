Rails.application.routes.draw do

  devise_for :users

  # MAIN ROUTE
  root 'nobrellas#index'
  #-----------------------------

  # Routes for the Event resource:
  # CREATE
  get "/events/new/:day", :controller => "events", :action => "new"
  post "/create_event", :controller => "events", :action => "create"

  # DUPLICATE
  get "/events/duplicate_right/:id", :controller => "events", :action => "duplicate_right"
  get "/events/duplicate_left/:id", :controller => "events", :action => "duplicate_left"

  # READ
  get "/events", :controller => "events", :action => "index"

  # UPDATE
  get "/events/:id/edit", :controller => "events", :action => "edit"
  post "/update_event/:id", :controller => "events", :action => "update"

  # DELETE
  get "/delete_event/:id", :controller => "events", :action => "destroy"
  #------------------------------

  # Routes for the Location resource:
  # CREATE
  get "/locations/new", :controller => "locations", :action => "new"
  post "/create_location", :controller => "locations", :action => "create"

  # READ
  get "/locations", :controller => "locations", :action => "index"

  # UPDATE
  get "/locations/:id/edit", :controller => "locations", :action => "edit"
  post "/update_location/:id", :controller => "locations", :action => "update"

  # DELETE
  get "/delete_location/:id", :controller => "locations", :action => "destroy"
  #------------------------------

end

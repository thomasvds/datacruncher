class EventController < ApplicationController
  def show
    @events = Event.all
  end
end

class EventController < ApplicationController
  def index
    start_date  = Date.parse('2016-06-13')
    end_date    = Date.today
    agents = Agent.all

    @xaxis, @volume = Event.volume_by_date(agents, start_date, end_date)
    @xaxis, @hour_of_last_action = Event.hour_of_last_action_by_date(agents, start_date, end_date)

    @time_split = {}
    agents.each do |agent|
      @time_split[agent.name] = Event.time_split(agent, start_date, end_date)
    end
  end
end



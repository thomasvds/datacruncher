class EventController < ApplicationController
  def show
    date_from  = Date.parse('2016-06-01')
    date_to    = Date.today
    date_range = date_from..date_to
    @xaxis = date_range.map {|d| d.strftime '%d/%m' }
    @events = Event.all
    @agents = Agent.all
    @series = Hash.new { |h, k| h[k] = []}
    @agents.each do |agent|
      date_range.each do |date|
        @series[agent] << Event.where(agent: agent, date: date).count || ""
      end
    end
  end
end



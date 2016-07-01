require 'active_support/core_ext/numeric/time'

class AgentController < ApplicationController
  before_action :set_agent

  def show
    start_date  = Date.parse('2016-06-20')
    end_date    = Date.parse('2016-06-26')
    date_range = start_date..end_date

    last_week_events = Event.where(agent: @agent, date: date_range)

    @policies_check_list, @score = Policy.check_list(last_week_events)

    @list_of_dates = date_range.map {|d| d.strftime '%a %d/%m' }
    @hour_of_last_event_by_date = Event.hour_of_last_event_by_date(@agent, date_range)

    @list_of_weeks, @all_time_score = all_time_score
  end

  private

  def set_agent
    @agent = Agent.find(params[:id])
  end

  def agent_params
    params.require(:agent).permit(:id)
  end

  def all_time_score
    start_date  = Date.parse('2016-04-01')
    end_date    = Date.parse('2016-06-26')

    agent_events = Event.where(agent: @agent)

    start_week = start_date.cweek
    end_week = end_date.cweek

    week_xaxis = start_week..end_week
    scores = []

    week = start_week

    while week <= end_week
      wkstart = Date.commercial(2016, week, 1)
      wkend = Date.commercial(2016, week, 7)
      date_range = wkstart..wkend
      events = agent_events.where(date: date_range)
      policies_check_list, score = Policy.check_list(agent_events.where(date: date_range))
      scores << score
      week += 1
    end

    averages = []
    averages[0] = scores[0]
    averages[1] = 0.5 * (scores[0] + scores[1])
    averages[2] = 0.33333 * (scores[0] + scores[1] + scores[2])
    (3...scores.count).each do |i|
      averages[i] = 0.25 * (scores[i-3] + scores[i-2] + scores[i-1] + scores[i])
    end



    return week_xaxis, {"weekly" => scores, "4-wks avg." => averages}
  end
end

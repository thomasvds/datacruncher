class ReportsController < ApplicationController
  before_action :set_agent, only: :individual

  def dashboard
    @per_agents = {}
    week_before_last_events = Event.where(date: Date.parse('2016-06-13')..Date.parse('2016-06-19'))
    last_week_events = Event.where(date: Date.parse('2016-06-20')..Date.parse('2016-06-26'))
    Agent.all.each do |agent|
      x, score_by_week, current_average_score, y = Policy.all_time_scores(agent)
      @per_agents[agent.name] = {
        "id" => agent.id,
        "last week" => {"score" => score_by_week["weekly"].last, "score_range" => Policy.score_range(score_by_week["weekly"].last)},
        "all time" => {"score" => current_average_score, "score_range" => Policy.score_range(current_average_score)}
      }
    end
  end

  def individual
    # Retrieve events
    start_date  = Date.parse('2016-06-20')
    end_date    = Date.parse('2016-06-26')
    date_range = start_date..end_date
    last_week_events = Event.where(agent: @agent, date: date_range)
    # Checklist of policies
    @policies_check_list,
    @week_score, @week_score_range = Policy.check_list(last_week_events)
    # Chart of this week late night activity
    @list_of_dates = date_range.map {|d| d.strftime '%a %d/%m' }
    @hour_of_last_event_by_date = Event.hour_of_last_event_by_date(@agent, date_range)
    # Chart of all time sustainability score
    @list_of_weeks,
    @score_by_week,
    @current_average_score,
    @current_average_score_range = Policy.all_time_scores(@agent)
    # Retrieve list of agents for drop-down selection of employee
    @agents = Agent.all
  end

  private

  def set_agent
    @agent = Agent.find(params[:id])
  end

end

require 'active_support/core_ext/numeric/time'

class AgentController < ApplicationController
  before_action :set_agent

  def show
    start_date  = Date.parse('2016-06-20')
    end_date    = Date.parse('2016-06-26')
    date_range = start_date..end_date

    last_week_events = Event.where(agent: @agent, date: date_range)

    @policies_check_list,
    @week_score, @week_score_range = Policy.check_list(last_week_events)

    @list_of_dates = date_range.map {|d| d.strftime '%a %d/%m' }
    @hour_of_last_event_by_date = Event.hour_of_last_event_by_date(@agent, date_range)

    @list_of_weeks,
    @score_by_week,
    @current_average_score,
    @current_average_score_range = Policy.all_time_scores(@agent)
  end

  private

  def set_agent
    @agent = Agent.find(params[:id])
  end

  def agent_params
    params.require(:agent).permit(:id)
  end

end

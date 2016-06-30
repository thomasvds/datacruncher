require 'active_support/core_ext/numeric/time'

class AgentController < ApplicationController
  before_action :set_agent

  def show
    start_date  = Date.parse('2016-06-20')
    end_date    = Date.parse('2016-06-26')
    @compliance = {}
    policies = Policy.where(enabled: true)
    events = Event.where(agent: @agent, date: start_date..end_date)
    @score = 0
    policies.each do |policy|
      policy_score = policy.compliant?(events)
      @compliance[policy.name] = policy_score
      policy_score ? num_score = 1 : num_score = 0
      @score = @score + policy.weight * num_score
    end
    @score = (@score * 100).round
    @xaxis, @hour_of_last_action = Event.hour_of_last_action_by_date(@agent, start_date, end_date)
    @week_xaxis, @all_time_score = all_time_score
  end

  def set_agent
    @agent = Agent.find(params[:id])
  end

  def agent_params
    params.require(:agent).permit(:id)
  end

  private

  def all_time_score
    start_date  = Date.parse('2016-04-01')
    end_date    = Date.parse('2016-06-26')

    agent_events = Event.where(agent: @agent)

    start_week = start_date.cweek
    end_week = end_date.cweek

    week_xaxis = start_week..end_week
    data = []

    week = start_week

    while week <= end_week
      wkstart = Date.commercial(2016, week, 1)
      wkend = Date.commercial(2016, week, 7)
      date_range = wkstart..wkend
      events = agent_events.where(date: date_range)
      score = 0
      Policy.all.each do |policy|
        policy_score = policy.compliant?(events)
        policy_score ? num_score = 1 : num_score = 0
        score = score + policy.weight * num_score
      end
      data << (score * 100).round
      week += 1
    end

    return week_xaxis, {"score" => data}
  end
end

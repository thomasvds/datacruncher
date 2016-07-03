class ReportsController < ApplicationController
  before_action :set_agent, only: :individual

  def dashboard
    @per_agents = {}
    week_before_last  = Date.parse('2016-06-13').cweek
    last_week  = Date.parse('2016-06-20').cweek
    Agent.all.each do |a|
      agent_score = Score.where(agent: a)

      last_week_score = agent_score.where(week: last_week).first
      last_week_score_range = Score.range(last_week_score.value)

      week_before_last_score = agent_score.where(week: week_before_last).first
      week_before_last_score_range = Score.range(week_before_last_score.value)

      current_average_score = Score.last_average(agent_score)
      current_average_score_range = Score.range(current_average_score)

      @per_agents[a.name] = {
        "last week" => {"score" => last_week_score.value.round, "score_range" => last_week_score_range},
        "week before last" => {"score" => week_before_last_score.value.round, "score_range" => week_before_last_score_range},
        "all time" => {"score" => current_average_score.round, "score_range" => current_average_score_range}
      }
    end
  end

  def individual
    # Retrieve events
    start_date  = Date.parse('2016-06-20')
    end_date    = Date.parse('2016-06-26')
    week = start_date.cweek
    date_range = start_date..end_date
    # Checklist of policies
    @policies_check_list = {}
    Policy.all.each do |p|
      if PolicySetting.where(policy: p).first.enabled
        @policies_check_list[p.name] = PolicyCheck.where(week: week, agent: @agent, policy: p).first.enforced
      end
    end
    # Chart of this week late night activity
    @list_of_dates = date_range.map {|d| d.strftime '%a %d/%m' }
    last_week_events = Event.where(agent: @agent, week: week)
    @hour_of_last_event_by_date = Event.hour_of_last_event_by_date(@agent, date_range)
    # Chart of all time sustainability score
    @list_of_weeks = 13..25

    score_by_week = Score.where(agent: @agent, week: @list_of_weeks).order(:week).pluck(:value)
    @current_week_score = score_by_week[-1].round
    @current_week_score_range = Score.range(@current_week_score)

    average_score_by_week = Score.moving_average(score_by_week)
    @current_average_score = average_score_by_week[-1].round
    @current_average_score_range = Score.range(@current_average_score)

    @scores_by_week = {"weekly" => score_by_week, "4 wks. avg." => average_score_by_week}

    # Retrieve list of agents for drop-down selection of employee
    @agents = Agent.all
  end

  private

  def set_agent
    @agent = Agent.find(params[:id])
  end

end

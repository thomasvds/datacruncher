class ReportsController < ApplicationController
  before_action :set_agent, only: :individual
  before_action :set_team, only: :team

  def dashboard
    @per_agents = {}
    # Define the current timeframe, currently hardcoded by to be
    # later made parameterizable by the user to get snapshots at different times
    week_before_last  = Date.parse('2016-06-26').cweek
    last_week  = Date.parse('2016-07-03').cweek
    Agent.all.each do |a|
      agent_score = Score.where(agent: a)
      # Retrieve score and score range for last week
      last_week_score = agent_score.where(week: last_week).first.weekly_value
      last_week_score_range = Score.range(last_week_score)
      # Retrieve score and score range for week before last
      week_before_last_score = agent_score.where(week: week_before_last).first.weekly_value
      week_before_last_score_range = Score.range(week_before_last_score)
      # Retrieve the current 4 weeks moving average score and range
      current_average_score = agent_score.where(week: last_week).first.moving_average_value
      current_average_score_range = Score.range(current_average_score)
      # Put all results in a hash for easier handling in the view
      @per_agents[a.name] = {
        "last week" => {
          "score" => last_week_score.round,
          "score_range" => last_week_score_range
          },
        "week before last" => {
          "score" => week_before_last_score.round,
          "score_range" => week_before_last_score_range
          },
        "all time" => {
          "score" => current_average_score.round,
          "score_range" => current_average_score_range
        }
      }
    end
  end

  def team
    week_before_last  = Date.parse('2016-06-26').cweek
    last_week  = Date.parse('2016-07-03').cweek
    members = @team.agents
    @team_results = {}
    members.each do |m|
      last_week_score = m.scores.where(week: last_week).first.weekly_value.round
      last_week_score_range = Score.range(last_week_score)
      week_before_last_score = m.scores.where(week: week_before_last).first.weekly_value.round
      week_before_last_score_range = Score.range(week_before_last_score)
      # Put all results in a hash for easier handling in the view
      @team_results[m.name] = {
        "employee" => {
          "name" => m.name,
          "id" => m.id,
          "position" => m.position,
          "picture" => m.picture_url
        },
        "scores" => {
          "last week" => {
            "value" => last_week_score,
            "range" => last_week_score_range
            },
          "week before last" => {
            "value" => week_before_last_score,
            "range" => week_before_last_score_range
          }
        }
      }
    end
  end

  def individual
    # Retrieve events for last week, to be made parameterizable
    start_date  = Date.parse('2016-06-27')
    end_date    = Date.parse('2016-07-03')
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
    @list_of_weeks = 13..end_date.cweek
    # Retrieve all scores for the agent, for the weeks in scope
    agent_scores_by_week = Score.where(agent: @agent, week: @list_of_weeks).order(:week)
    # Retrieve weekly scores values and ranges
    weekly_score_by_week = agent_scores_by_week.pluck(:weekly_value)
    @current_weekly_score = agent_scores_by_week.where(week: week).first.weekly_value.round
    @current_weekly_score_range = Score.range(@current_weekly_score)
    # Retrieve 4-weeks moving average scores values and ranges
    moving_average_score_by_week = agent_scores_by_week.pluck(:moving_average_value)
    @current_moving_average_score = agent_scores_by_week.where(week: week).first.moving_average_value.round
    @current_moving_average_score_range = Score.range(@current_moving_average_score)
    # Put the results in a hash for passing as argument to highcharts chart
    @scores_by_week = {
      "weekly" => weekly_score_by_week,
      "4 wks. avg." => moving_average_score_by_week
    }
    # Retrieve list of agents for drop-down selection of employee
    @agents = Agent.all
  end

  private

  def set_agent
    @agent = Agent.find(params[:id])
  end

  def set_team
    @team = Team.find(params[:id])
  end

end

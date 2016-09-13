require 'date'

class ReportsController < ApplicationController
  before_action :set_agent, only: :individual
  before_action :set_team, only: :team

  def company

    # today must be a Sunday
    params[:date].nil? ? today = Date.parse('2016-08-14') : today = Date.parse(params[:date])
    last_week  = today.cweek
    week_before_last = last_week - 1

    # DATA FOR INDIVIDUAL SCORES TABLE
    @per_agents = {}
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
      @per_agents[a.id] = {
        "employee" => {
          "id" => a.id,
          "name" => a.name,
          "position" => a.position
          },
          "scores" => {
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
            }
          end

    # DATA FOR COMPANY-WIDE SUSTAINABILITY SCORE & RANGES EVOLUTION
    # Retrieve events for last week, to be made parameterizable
    end_date    = today
    # Chart of all time sustainability score
    @list_of_weeks = (1..end_date.cweek).to_a
    # Retrieve all scores for the team, for the weeks in scope
    company_scores = Score.where(week: @list_of_weeks).order(:week)
    # Instantiate the hashes that will contain the output
    @company_average_weekly_score_by_week = Hash.new {|h,k| h[k] = [] }
    @company_score_ranges_share_by_week = Hash.new {|h,k| h[k] = [] }
    # Go through each week in scope and fill in the hashes
    @list_of_weeks.each do |w|
      # Select the scores in scope and extract them to an array that can be processed
      weekly_values = company_scores.where(week: w).pluck(:weekly_value)
      # Fill in the different ranges
      @company_score_ranges_share_by_week["Great"] << weekly_values.count { |v| Score.range(v) == "success" }
      @company_score_ranges_share_by_week["Good"] << weekly_values.count { |v| Score.range(v) == "primary" }
      @company_score_ranges_share_by_week["Warning"] << weekly_values.count { |v| Score.range(v) == "warning" }
      @company_score_ranges_share_by_week["Danger"] << weekly_values.count { |v| Score.range(v) == "danger" }
      # Fill in the average across all agents for the week
      @company_average_weekly_score_by_week["Company average"] << (weekly_values.reduce(:+).to_f / weekly_values.size).round(1)
    end

    # DATA FOR POLICIES GAUGES
    last_week_policy_checks = PolicyCheck.where(week: last_week)
    number_of_employees = Agent.all.count
    @policies_enforcement = {}
    Policy.all.each do |p|
      if p.policy_setting.enabled
        number_enforced = last_week_policy_checks.where(policy: p, enforced: true).count
        policy_enforcement_percentage = (number_enforced.fdiv(number_of_employees) * 100).round
        @policies_enforcement[p.id] = { "name" => p.name, "score" => policy_enforcement_percentage, "weight" => (p.policy_setting.weight * 100).round(1) }
      end
    end

    # DATA FOR NUMBER OF AGENTS PER SCORE BOX
    @score_ranges_boxes_data = score_range_boxes(last_week)

    # DATA FOR POLICIES TABLE PER TEAM
    @policies_per_team_data = []
    @policies_headers = []

    Policy.all.each do |policy|
      if policy.policy_setting.enabled
        @policies_headers << policy.name
      end
    end

    Team.all.each do |team|

      score = team_score(team, last_week)
      range = Score.range(score)

      values = []
      ranges = []

      Policy.all.each do |policy|
        if policy.policy_setting.enabled
          policy_score = team_policy_percentage(team, policy, last_week)
          values << policy_score
          ranges << Score.range(policy_score)
        end
      end

      team_results =
      {
        "team" => {
          "id" => team.id,
          "name" => team.name,
        },
        "total score" => {
          "value" => score,
          "range" => range
        },
        "policy scores" => {
          "values" => values,
          "ranges" => ranges
        }
      }

      p team_results

      @policies_per_team_data.push(team_results)
    end

  end




  def team

    # today must be a Sunday
    params[:date].nil? ? today = Date.parse('2016-08-14') : today = Date.parse(params[:date])
    last_week  = today.cweek
    week_before_last = last_week - 1
    # DATA FOR INDIVIDUAL TEAM MEMBERS SCORES
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

    # DATA FOR POLICIES GAUGES
    last_week_policy_checks = PolicyCheck.where(week: last_week, agent: members)
    number_of_employees = members.count
    @policies_enforcement = {}
    Policy.all.each do |p|
      if p.policy_setting.enabled
        number_enforced = last_week_policy_checks.where(policy: p, enforced: true).count
        policy_enforcement_percentage = (number_enforced.fdiv(number_of_employees) * 100).round
        @policies_enforcement[p.id] = { "name" => p.name, "score" => policy_enforcement_percentage, "weight" => (p.policy_setting.weight * 100).round(1) }
      end
    end

    # DATA FOR TEAM SCORE EVOLUTION
    # Retrieve events for last week, to be made parameterizable
    end_date    = today
    start_date = today - 6 #as today is a Sunday, start_date is a Monday
    week = start_date.cweek
    date_range = start_date..end_date
    # Chart of all time sustainability score
    @list_of_weeks = (27..end_date.cweek).to_a
    # Retrieve all scores for the team, for the weeks in scope
    team_scores = Score.where(agent: members, week: @list_of_weeks).order(:week)
    # Retrieve the team average score
    team_average = []
    @list_of_weeks.each do |w|
      values = team_scores.where(week: w).pluck(:weekly_value)
      team_average << (values.reduce(:+).to_f / values.size).round(1)
    end
    # Retrieve the individual weekly scores
    score = {}
    members.each do |m|
      score[m.name] = team_scores.where(agent: m).pluck(:weekly_value)
    end
    @team_score_by_week = {"Team average" => team_average}.merge(score)
    @current_team_average_score = {"value" => team_average.last.round, "range" => Score.range(team_average.last)}

    # OTHER DATA
    # For drop-down enabling team selection
    @teams = Team.all
  end

  def individual

    # DATA FOR POLICY COMPLIANCE
    # Retrieve dates for last week, to be made parameterizable
    # today must be a Sunday
    params[:date].nil? ? today = Date.parse('2016-08-14') : today = Date.parse(params[:date])
    start_date  = today - 6
    end_date    = today

    week = start_date.cweek
    date_range = start_date..end_date
    # Checklist of policies
    @policies_check_list = {}
    Policy.all.each do |p|
      if PolicySetting.where(policy: p).first.enabled
        @policies_check_list[p.name] = PolicyCheck.where(week: week, agent: @agent, policy: p).first.enforced
      end
    end

    # DATA FOR LATE-NIGHT ACTIVITY
    # Chart of this week late night activity
    @list_of_dates = date_range.map {|d| d.strftime '%a %d/%m' }
    last_week_events = Event.where(agent: @agent, week: week)
    @hour_of_last_event_by_date = Event.hour_of_last_event_by_date(@agent, date_range)

    # DATA FOR SUSTAINABILITY SCORE EVOLUTION
    # Chart of all time sustainability score
    @list_of_weeks = (1..end_date.cweek).to_a
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

    # OTHER DATA
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

  def team_score(team, week)
    members_scores = Score.where(agent: team.agents, week: week).pluck(:weekly_value)
    return members_scores.sum.fdiv(members_scores.count).round
  end

  def team_policy_percentage(team, policy, week)
    number_enforced = PolicyCheck.where(week: week, policy: policy, agent: team.agents, enforced: true).count
    return (number_enforced.fdiv(team.agents.count) * 100).round
  end

  def score_range_boxes(week)
    ranges = ['great', 'good', 'warning', 'danger']
    response = []
    ranges.each do |range|
      element = {}
      element['range_name'] = range
      element['week_count'] = count_per_score_range(range, week)
      element['previous_week_count'] = count_per_score_range(range, week - 1)
      delta = element['week_count'] - element['previous_week_count']
      case
      when delta == 0
        element['evolution'] = 'right'
      when delta > 0
        element['evolution'] = 'up'
      when delta < 0
        element['evolution'] = 'down'
      end
      response << element
    end
    return response
  end

  def count_per_score_range(range, week)
    case range
    when 'danger'
      values = [0..40]
    when 'warning'
      values = [41..60]
    when 'good'
      values = [61..80]
    when 'great'
      values = [81..100]
    end
    return Score.where(week: week, weekly_value: values).count
  end

end

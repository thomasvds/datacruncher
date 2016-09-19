require 'date'

class ReportsController < ApplicationController
  before_action :set_agent, only: :individual
  before_action :set_team, only: :team
  before_action :set_date

  include Calculations::Utilities
  include Calculations::Individuals
  include Calculations::Groups::Scores
  include Calculations::Groups::Policies

  def company
    agents = Agent.all

    # NUMBER OF AGENTS PER SCORE BOX AND TRENDS
    @score_ranges_boxes_data = all_score_ranges_weekly_evolution_overview(agents, @week, @year)

    # COMPANY POLICIES GAUGES
    @policies_enforcement_data = all_policies_weekly_percentage_overview(agents, @week, @year)

    # SCORE AND POLICIES TABLE PER TEAM
    @policies_headers = Policy.enabled.map { |p| p.name }
    @policies_per_team_data = []
    Team.all.each do |team|
      members = team.agents
      score = group_score(members, @week, @year)
      range = value_range(score)
      @policies_per_team_data << {
        "team" => team.info_hash,
        "total score" => {"value" => score, "range" => range},
        "policy values" => all_policies_weekly_percentage_overview(members, @week, @year)
      }
    end

    # INDIVIDUAL SCORES TABLE
    @per_agents_data = []
    agents.each do |a|
      @per_agents_data << {
        "agent" => a.info_hash,
        "scores" => individual_scores_snapshot(a, @week, @year)
      }
    end

    # COMPANY SUSTAINABILITY SCORE & RANGES EVOLUTION
    @list_of_weeks = (1..@week).to_a
    @company_average_weekly_score_by_week = Hash.new {|h,k| h[k] = [] }
    @company_score_ranges_share_by_week = Hash.new {|h,k| h[k] = [] }
    @list_of_weeks.each do |w|
      Calculations::RANGE.each do |range_name, range_values|
        @company_score_ranges_share_by_week[range_name] << count_per_score_range(agents, range_name, w, @year)
      end
      @company_average_weekly_score_by_week["Company average"] << group_score(agents, w, @year)
    end
  end

  def team

    # INDIVIDUAL TEAM MEMBERS SCORES
    @team_members_scores_data = []
    @members.each do |m|
      @team_members_scores_data << {
        "agent" => m.info_hash,
        "scores" => individual_scores_snapshot(m, @week, @year)
      }
    end

    # TEAM POLICIES GAUGES
    @policies_enforcement_data = all_policies_weekly_percentage_overview(@members, @week, @year)

    # TEAM SCORES EVOLUTION
    @list_of_weeks = (27..@week).to_a
    # team average score
    team_average = []
    @list_of_weeks.each do |w|
      team_average << group_score(@members, w, @year)
    end
    # individual weekly scores
    score = {}
    @members.each do |m|
      score[m.name] = Score.where(agent: m, week: @list_of_weeks, year: @year).pluck(:weekly_value)
    end
    @team_score_by_week = {"Team average" => team_average}.merge(score)
    @current_team_average_score = {"value" => team_average.last, "range" => value_range(team_average.last)}

    # DROP-DOWN SELECTOR
    @teams = Team.all
  end

  def individual

    # POLICIES CHECKLIST (use 100% as checked, 0% as unchecked)
    @policies_check_list = all_policies_weekly_percentage_overview(@agent, @week, @year)

    # LATE-NIGHT ACTIVITY
    @list_of_dates = @week_dates.map {|d| d.strftime '%a %d/%m' }
    @hour_of_last_event_by_date = Event.hour_of_last_event_by_date(@agent, @week_dates)

    # CURRENT SCORE SNAPSHOT
    @scores = individual_scores_snapshot(@agent, @week, @year)

    # SCORE EVOLUTION
    @list_of_weeks = (1..@week).to_a
    agent_scores_by_week = Score.where(agent: @agent, week: @list_of_weeks).order(:week)
    @scores_by_week = {
      "weekly" => agent_scores_by_week.pluck(:weekly_value),
      "4 wks. avg." => agent_scores_by_week.pluck(:moving_average_value)
    }

    # DROP-DOWN SELECTOR
    @agents = Agent.all
  end

  private

  def set_agent
    @agent = Agent.find(params[:id])
  end

  def set_team
    @team = Team.find(params[:id])
    @members = @team.agents
  end

  # TODO: handle the case of week 1
  def set_date
    params[:date].nil? ? @today = Date.parse('2016-08-14') : @today = Date.parse(params[:date])
    @week  = @today.cweek
    @year = @today.year
    one_week_ago = @today - 6
    @week_dates = one_week_ago..@today
  end
end

require 'test_helper'
include Calculations::Groups::Scores
# Note that Calculations::Utilities needs to be included as it is used in
# the Scores submodules
include Calculations::Utilities
include Calculations::Individuals

# To run this specific test only, run:
# rake test TEST=test/modules/calculations_scores_test.rb

class CalculationsScoresTest < ActiveSupport::TestCase
  def setup
    @week = 32
    @week_with_no_score = 1
    @year = 2016
    @agent = Agent.create(name: "John Doe")
    @agent_2 = Agent.create(name: "Smith Anderson")
    @agent_3 = Agent.create(name: "Daniel Johnson")
    @group_with_scores = [@agent, @agent_2]
    @group_with_missing_score = Agent.all
    Score.create(agent: @agent, week: @week, year: @year, weekly_value: 80, moving_average_value: 25)
    Score.create(agent: @agent, week: @week-1, year: @year, weekly_value: 80, moving_average_value: 25)
    Score.create(agent: @agent_2, week: @week, year: @year, weekly_value: 100, moving_average_value: 25)
    Score.create(agent: @agent_2, week: @week-1, year: @year, weekly_value: 100, moving_average_value: 25)
    @previous_score = Score.create(agent: @agent, week: @week - 1, year: @year, weekly_value: 25, moving_average_value: 25)
  end

  test "group_weekly_score raises an error if agents contains zero agents" do
    assert_raise ArgumentError do
      group_weekly_score([], @week, @year)
    end
  end

  test "group_weekly_score raises an error if agents is a single agent not part of a collection" do
    assert_raise ArgumentError do
      group_weekly_score(@agent, @week, @year)
    end
  end

  test "group_weekly_score returns an integer score" do
    assert_instance_of Fixnum, group_weekly_score(@group_with_scores, @week, @year)
  end

  test "group_weekly_score returns the average of group members scores, when all members have a score" do
    assert_equal 90, group_weekly_score(@group_with_scores, @week, @year)
  end

  test "group_weekly_score returns the average of group members scores, when not all members have a score" do
    assert_equal 90, group_weekly_score(@group_with_missing_score, @week, @year)
  end

  test "group_weekly_score returns nil when no scores exist for the week" do
    assert_equal nil, group_weekly_score(@group_with_scores, @week_with_no_score, @year)
  end

  test "group_array_of_info_and_scores raises an error if agents contains zero agents" do
    assert_raise ArgumentError do
      group_array_of_info_and_scores([], @week, @year)
    end
  end

  test "group_array_of_info_and_scores raises an error if agents is a single agent not part of a collection" do
    assert_raise ArgumentError do
      group_array_of_info_and_scores(@agent, @week, @year)
    end
  end

  test "group_array_of_info_and_scores returns an array of hashes with agent info and scores" do
    result = group_array_of_info_and_scores(@group_with_scores, @week, @year)
    assert_instance_of Array, result
    element = result[0]
    assert_instance_of Hash, element
    assert_includes element, :agent
    assert_includes element, :scores
  end

  test "group_array_of_info_and_scores returns an array of hashes with one hash per agent" do
    result = group_array_of_info_and_scores(@group_with_scores, @week, @year)
    assert_equal result.count, @group_with_scores.count
  end

  test "count_per_score_range raises an error if agents contains zero agents" do
    assert_raise ArgumentError do
      count_per_score_range([], 'good', @week, @year)
    end
  end

  test "count_per_score_range raises an error if agents is a single agent not part of a collection" do
    assert_raise ArgumentError do
      count_per_score_range(@agent, 'good', @week, @year)
    end
  end

  test "count_per_score_range raises an error if range is not part of the defined list of range" do
    assert_raise ArgumentError do
      count_per_score_range(@group_with_scores, 'foo', @week, @year)
    end
  end

  test "count_per_score_range returns the number of agents with a score in the range" do
    assert_equal 1,count_per_score_range(@group_with_scores, 'great', @week, @year)
    assert_equal 1,count_per_score_range(@group_with_scores, 'good', @week, @year)
  end

  test "score_range_weekly_evolution_snapshot raises an error if agents contains zero agents" do
    assert_raise ArgumentError do
      score_range_weekly_evolution_snapshot([], 'good', @week, @year)
    end
  end

  test "score_range_weekly_evolution_snapshot raises an error if agents is a single agent not part of a collection" do
    assert_raise ArgumentError do
      score_range_weekly_evolution_snapshot(@agent, 'good', @week, @year)
    end
  end

  test "score_range_weekly_evolution_snapshot raises an error if range is not part of the defined list of range" do
    assert_raise ArgumentError do
      score_range_weekly_evolution_snapshot(@group_with_scores, 'foo', @week, @year)
    end
  end

  test "score_range_weekly_evolution_snapshot returns a hash with week count, previous week count, and trend" do
    result = score_range_weekly_evolution_snapshot(@group_with_scores, 'good', @week, @year)
    assert_instance_of Hash, result
    assert_includes result, :week_count
    assert_includes result, :previous_week_count
    assert_includes result, :evolution
  end

  test "all_score_ranges_weekly_evolution_overview raises an error if agents contains zero agents" do
    assert_raise ArgumentError do
      all_score_ranges_weekly_evolution_overview([], @week, @year)
    end
  end

  test "all_score_ranges_weekly_evolution_overview raises an error if agents is a single agent not part of a collection" do
    assert_raise ArgumentError do
      all_score_ranges_weekly_evolution_overview(@agent, @week, @year)
    end
  end

  test "all_score_ranges_weekly_evolution_overview returns an array of hashes with range, week count, previous week count, and trend" do
    result = all_score_ranges_weekly_evolution_overview(@group_with_scores, @week, @year)
    assert_instance_of Array, result
    element = result[0]
    assert_instance_of Hash, element
    assert_includes element, :range
    assert_includes element, :week_count
    assert_includes element, :previous_week_count
    assert_includes element, :evolution
  end

  test "all_score_ranges_weekly_evolution_overview returns an array of hashes with one hash per range" do
    result = all_score_ranges_weekly_evolution_overview(@group_with_scores, @week, @year)
    assert_equal result.count, Calculations::RANGE.count
  end
end

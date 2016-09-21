require 'test_helper'
include Calculations::Individuals
# Note that Calculations::Utilities needs to be included as it is used in
# the Individuals submodules
include Calculations::Utilities

# To run this specific test only, run:
# rake test TEST=test/modules/calculations_individuals_test.rb

class CalculationsIndividualsTest < ActiveSupport::TestCase
  def setup
    @week = 32
    @year = 2016
    @agent = Agent.create(name: "John Doe")
    @agent_2 = Agent.create(name: "Smith Anderson")
    @score = Score.create(agent: @agent, week: @week, year: @year, weekly_value: 50, moving_average_value: 25)
    @previous_score = Score.create(agent: @agent, week: @week - 1, year: @year, weekly_value: 25, moving_average_value: 25)
  end

  test "individual_week_score_and_range returns a hash with score and range" do
    result = individual_week_score_and_range(@agent, @week, @year)
    assert_instance_of Hash, result
    assert_includes result, :score
    assert_includes result, :range
  end

  test "individual_week_score_and_range raises an error if given a collection of agents" do
    assert_raise ArgumentError do
      individual_week_score_and_range(Agent.all, @week, @year)
    end
  end

  test "individual_moving_average_score_and_range returns a hash with score and range" do
    result = individual_moving_average_score_and_range(@agent, @week, @year)
    assert_instance_of Hash, result
    assert_includes result, :score
    assert_includes result, :range
  end

  test "individual_moving_average_score_and_range raises an error if given a collection of agents" do
    assert_raise ArgumentError do
      individual_moving_average_score_and_range(Agent.all, @week, @year)
    end
  end

  test "individual_scores_snapshot raises an error if given a collection of agents" do
    assert_raise ArgumentError do
      individual_scores_snapshot(Agent.all, @week, @year)
    end
  end

  test "individual_scores_snapshot returns a hash with week score, previous week score, and moving average score as three hashes" do
    result = individual_scores_snapshot(@agent, @week, @year)
    assert_instance_of Hash, result
    assert_includes result, :week
    assert_instance_of Hash, result[:week]
    assert_includes result, :previous_week
    assert_instance_of Hash, result[:previous_week]
    assert_includes result, :moving_average
    assert_instance_of Hash, result[:moving_average]
  end
end

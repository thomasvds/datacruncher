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
    @score = Score.create(agent: @agent, week: @week, year: @year, weekly_value: 50)
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
end

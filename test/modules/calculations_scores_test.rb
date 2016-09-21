require 'test_helper'
include Calculations::Groups::Scores
# Note that Calculations::Utilities needs to be included as it is used in
# the Scores submodules
include Calculations::Utilities

# To run this specific test only, run:
# rake test TEST=test/modules/calculations_scores_test.rb

class CalculationsScoresTest < ActiveSupport::TestCase
  def setup
    @week = 32
    @year = 2016
    @agent = Agent.create(name: "John Doe")
    @agent_2 = Agent.create(name: "Smith Anderson")
    @score = Score.create(agent: @agent, week: @week, year: @year, weekly_value: 50, moving_average_value: 25)
    @previous_score = Score.create(agent: @agent, week: @week - 1, year: @year, weekly_value: 25, moving_average_value: 25)
  end
end

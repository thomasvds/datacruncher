require 'test_helper'

class ScoreTest < ActiveSupport::TestCase
  def setup
    agent = agents(:sophia)
    @week = 9
    @year = 2016
    @weekly_value = 65.45
    @moving_average_value = 0
    @score = Score.new(agent: agent, week: @week, year: @year,
      weekly_value: @weekly_value, moving_average_value: @moving_average_value)
  end

  test "score belongs to an agent" do
    assert_not @score.agent.nil?, "missing association: score has no agent"
  end

  test "score has a week attribute" do
    assert_not @score.week.nil?, "missing attribute: score has no week"
  end

  test "week is an integer" do
    assert @week.is_a?(Integer), "wrong value: week is not an integer"
  end

  test "week comprised between 1 and 52" do
    assert Score::WEEKS.cover?(@score.week), "wrong value:
    week number must be comprised between 1 and 52 (incl)"
  end

  test "score has a year attribute" do
    assert_not @score.year.nil?, "missing attribute: score has no year"
  end

  test "year is an integer" do
    assert @year.is_a?(Integer), "wrong value: year is not an integer"
  end

  test "year comprised between 2000 and the year as of today" do
    assert Score::YEARS.cover?(@score.year), "wrong value:
    year number must be comprised between 2000 and the year as of today (incl)"
  end

  test "year and week are uniquely associated" do
    @score.save
    duplicated_score = @score.dup
    assert_not duplicated_score.valid?, "wrong association: year and week are not uniquely associated"
  end

  test "score has a weekly_value" do
    assert_not @score.weekly_value.nil?, "missing attribute: score has no weekly_value"
  end

  test "weekly_value is a numeric" do
    assert @weekly_value.is_a?(Numeric), "wrong value: weekly_value is not a numeric"
  end

  test "weekly_value comprised between 0 and 100" do
    assert Score::PERCENTAGES.cover?(@weekly_value), "wrong value:
    weekly_value must be comprised between 0 and 100 (incl)"
  end

  test "score has a moving_average_value" do
    assert_not @score.moving_average_value.nil?, "missing attribute: score has no moving_average_value"
  end

  test "moving_average_value is a numeric" do
    assert @moving_average_value.is_a?(Numeric), "wrong value: moving_average_value is not a numeric"
  end

  test "moving_average_value comprised between 0 and 100" do
    assert Score::PERCENTAGES.cover?(@moving_average_value), "wrong value:
    moving_average_value must be comprised between 0 and 100 (incl)"
  end

  test "score is valid" do
    assert @score.valid?, "validation error: event is not valid"
  end
end

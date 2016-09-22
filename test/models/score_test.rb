require 'test_helper'

class ScoreTest < ActiveSupport::TestCase
  def setup
    @agent = agents(:sophia)
    @week = 9
    @year = 2016
    @weekly_value = 65.45
    @moving_average_value = 67.98
    @params = { agent: @agent, week: @week, year: @year, weekly_value: @weekly_value,
      moving_average_value: @moving_average_value }
  end

  test "score validates presence of agent" do
    @params[:agent] = nil
    score = Score.create(@params)
    assert_includes score.errors.messages[:agent], "can't be blank"
  end

  test "score validates presence of week" do
    @params[:week] = nil
    score = Score.create(@params)
    assert_includes score.errors.messages[:week], "can't be blank"
  end

  test "score validates week is an integer" do
    @params[:week] = 23.3
    score = Score.create(@params)
    assert_includes score.errors.messages[:week], "must be an integer"
  end

  test "score validates week comprised between the WEEKS constant" do
    @params[:week] = 53
    score = Score.create(@params)
    assert_includes score.errors.messages[:week], "is not included in the list"
  end

  test "score validates presence of year" do
    @params[:year] = nil
    score = Score.create(@params)
    assert_includes score.errors.messages[:year], "can't be blank"
  end

  test "score validates year is an integer" do
    @params[:year] = 2015.23
    score = Score.create(@params)
    assert_includes score.errors.messages[:year], "must be an integer"
  end

  test "score validates week comprised between the YEARS constant" do
    @params[:year] = 2018
    score = Score.create(@params)
    assert_includes score.errors.messages[:year], "is not included in the list"
  end

  test "year and week are uniquely associated" do
    score = Score.create(@params)
    another_score = Score.new(@params)
    assert another_score.invalid?
  end

  test "score validates presence of weekly_value" do
    @params[:weekly_value] = nil
    score = Score.create(@params)
    assert_includes score.errors.messages[:weekly_value], "can't be blank"
  end

  test "score validates weekly_value is a numeric (float or integer)" do
    @params[:weekly_value] = "hello"
    score = Score.create(@params)
    assert_includes score.errors.messages[:weekly_value], "is not a number"
  end

  test "score validates weekly_value comprised between the PERCENTAGES constant" do
    @params[:weekly_value] = 101
    score = Score.create(@params)
    assert_includes score.errors.messages[:weekly_value], "is not included in the list"
  end

  test "score validates presence of moving_average_value" do
    @params[:moving_average_value] = nil
    score = Score.create(@params)
    assert_includes score.errors.messages[:moving_average_value], "can't be blank"
  end

  test "score validates moving_average_value is a numeric (float or integer)" do
    @params[:moving_average_value] = "hello"
    score = Score.create(@params)
    assert_includes score.errors.messages[:moving_average_value], "is not a number"
  end

  test "score validates moving_average_value comprised between the PERCENTAGES constant" do
    @params[:moving_average_value] = 101
    score = Score.create(@params)
    assert_includes score.errors.messages[:moving_average_value], "is not included in the list"
  end

  test "score is valid" do
    score = Score.create(@params)
    assert score.valid?
  end
end

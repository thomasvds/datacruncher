require 'test_helper'
include Calculations
include Calculations::Individuals
include Calculations::Groups::Policies
include Calculations::Utilities

# To run this specific test only, run:
# rake test TEST=test/integration/report_team_test.rb

class ReportTeamTest < ActionDispatch::IntegrationTest

  # Setup a team
  def setup
    super # <-- Required to load the seeds, Rails.application.load_seed
    rand_number = rand(1..Team.count)
    @team = Team.where(id: rand_number).first
  end

  # Debug an integration test
  def debug(page)
    puts page.html
    save_and_open_page
    save_and_open_screenshot
  end

  # test "loads correctly" do
  #   visit "reports/team/#{@team.id}"
  #   assert_equal 200 , page.status_code
  # end

  # test "overview team members displays correct number of staffings" do
  #   visit "reports/team/#{@team.id}"
  #   assert_equal page.all(".individual-small-card").count, @team.staffings.count
  # end

  # test "all values in overview team members are percentages between 0 and 100%" do
  #   visit "reports/team/#{@team.id}"
  #   page.all(".individual-small-card .content .score").each do |item|
  #      value = item.text

  #      matching = value.match(/\A\d{1,3}%\z/)
  #      assert_not matching.nil?

  #      number = matching[0].match(/\d+/)
  #      assert_includes 0..100 , number[0].to_i
  #   end
  # end

  # test "individual team score percentage corresponds to effectve last score" do
  #   visit "reports/team/#{@team.id}"
  #   agents = []
  #   @team.staffings.each do |team_individual|
  #     agents << Agent.where(id: team_individual.agent_id).first
  #   end
  #   scores = []
  #   agents.each do |agent|
  #     scores << Score.where(agent_id: agent.id).last.weekly_value.round(Calculations::METRICS_ROUNDING_LEVEL)
  #   end
  #   numbers = []
  #   page.all(".individual-small-card .content .score").each do |item|
  #     value = item.text
  #     matching = value.match(/\A\d{1,3}%\z/)
  #     numbers << matching[0].match(/\d+/)[0].to_i
  #   end
  #   assert_equal scores, numbers
  # end

  test "displays one gauge for each enabled policy in worklife balance drivers" do
    visit "reports/team/#{@team.id}"
    Policy.enabled.each do |policy|
      assert page.first("#collapse-team-gauges").has_content?(policy.name)
    end
  end

  test "does not display gauges for policies that are not enabled" do
    visit "reports/team/#{@team.id}"
    assert page.first("#collapse-team-gauges").has_selector?(".highcharts-container", count: Policy.enabled.count)
  end

  test "gauge policy scores are all comprised between 0 and 100%" do
    visit "reports/team/#{@team.id}"
    page.first("#collapse-team-gauges").all(".highcharts-container").each do |chart|
      content =  chart.first("span").text
      value = content.match(/\d+/)[0].to_i
      assert_includes 0..100, value
    end
  end
end

require 'test_helper'
include Calculations
include Calculations::Individuals
include Calculations::Groups::Policies
include Calculations::Utilities

# To run this specific test only, run:
# rake test TEST=test/integration/report_team_test.rb

class ReportTeamTestTest < ActionDispatch::IntegrationTest

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

  test "loads correctly" do
    visit "reports/team/#{@team.id}"
    assert_equal 200 , page.status_code
  end

  # test "display overvview of all team members sustainability scores" do
  #   ""
  # end
end

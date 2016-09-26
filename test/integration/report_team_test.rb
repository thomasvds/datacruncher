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
    super # <-- Required to load the seeds
    @team = Team.first
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
end

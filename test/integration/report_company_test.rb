require 'test_helper'

# To run this specific test only, run:
# rake test TEST=test/integration/report_company_test.rb

class ReportCompanyTest < ActionDispatch::IntegrationTest
  def setup
    Rails.application.load_seed
  end

  test "loads correctly" do
    p "**********"
    p "=====In Test, the Agent.all command returns:====="
    p Agent.all
    p "**********"
    visit 'reports/company'
    # save_and_open_screenshot
    assert_equal 200 , page.status_code

    # assert page.has_content?("about")
  end
end

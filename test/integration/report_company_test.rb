require 'test_helper'

# To run this specific test only, run:
# rake test TEST=test/integration/report_company_test.rb

class ReportCompanyTest < ActionDispatch::IntegrationTest
  test "loads correctly" do
    visit 'reports/company'
    assert_equal 200 , page.status_code
  end
end

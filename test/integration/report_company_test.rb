require 'test_helper'
include Calculations

# To run this specific test only, run:
# rake test TEST=test/integration/report_company_test.rb

class ReportCompanyTest < ActionDispatch::IntegrationTest
  test "loads correctly" do
    visit 'reports/company'
    assert_equal 200 , page.status_code
  end

  test "displays one score box per range" do
    visit 'reports/company'
    Calculations::RANGE.each do |range_name, range_values|
      page.should have_css("panel-#{range_name}", :count => 2)
    end
  end

  # test "current score range figures add up to number of employees in company" do
  #   visit 'reports/company'
  # end

  # test "previous week score range figures add up to number of employees in company" do
  #   visit 'reports/company'
  # end

  # test "displays one gauge per policy, for enabled policies only" do
  #   visit 'reports/company'
  # end

  # test "policy scores are all comprised between 0 and 100%" do
  #   visit 'reports/company'
  # end

  # test "displays table with one row per individual" do
  #   visit 'reports/company'
  # end

  # test "all elements in individual table are numeric percentages" do
  #   visit 'reports/company'
  # end

  # test "displays table with one row per team" do
  #   visit 'reports/company'
  # end

  # test "all elements in team table are numeric percentages" do
  #   visit 'reports/company'
  # end
end

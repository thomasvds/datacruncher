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
      assert page.has_selector?(".panel-#{range_name}", count: 1)
    end
  end

  test "current score range figures add up to number of employees in company" do
    visit 'reports/company'
    sum = 0
    Calculations::RANGE.each do |range_name, range_values|
      sum += page.first(".panel-#{range_name}").first(".huge").text.to_i
    end
    assert_equal Agent.all.count , sum
  end

  test "previous week score range figures add up to number of employees in company" do
    visit 'reports/company'
    sum = 0
    Calculations::RANGE.each do |range_name, range_values|
      content = page.first(".panel-#{range_name}").first(".pull-left").text
      value = content.match(/\d+/)[0].to_i
      sum += value
    end
    assert_equal Agent.all.count , sum
  end

  test "displays one gauge for each enabled policy" do
    visit 'reports/company'
    Policy.enabled.each do |policy|
      assert page.first(".panel-default").has_content?(policy.name)
    end
  end

  test "does not display gauges for policies that are not enabled" do
    visit 'reports/company'
    Policy.enabled.each do |policy|
      assert page.first(".panel-default").has_content?(policy.name)
    end
    assert page.first(".panel-default").has_selector?(".highcharts-container", count: Policy.enabled.count)
  end

  test "gauge policy scores are all comprised between 0 and 100%" do
    visit 'reports/company'
    page.first(".panel-default").all(".highcharts-container").each do |chart|
      content =  chart.first("span").text
      value = content.match(/\d+/)[0].to_i
      assert_includes 0..100, value
    end
  end

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

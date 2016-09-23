require 'test_helper'
include Calculations
include Calculations::Individuals
include Calculations::Groups::Policies
include Calculations::Utilities

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

  test "contains a table with one row for each team" do
    visit 'reports/company'
    assert_equal Team.all.count, page.all("#collapse-teams-table table tbody tr").count
  end

  test "the teams table headers contain all enabled policies" do
    visit 'reports/company'
    Policy.enabled.each do |policy|
      assert page.find("#collapse-teams-table table thead").has_content?(policy.name)
    end
  end

  test "the teams table headers do not contain disabled policies" do
    visit 'reports/company'
    Policy.all.each do |policy|
      if !policy.enabled?
        assert_not page.find("#collapse-teams-table table thead").has_content?(policy.name)
      end
    end
  end

  # Note: we take the first team, and will check each value
  test "the teams table values are the value of policies referred to in the headers" do
    date = '18/09/2016'
    visit "reports/company?date=#{date}"
    # Process headers (policies start at 3rd column)
    policy_headers = page.all("#collapse-teams-table th").drop(2)
    # Retrieve the information in the first row
    row = page.first("#collapse-teams-table table tbody tr").all("td")
    # Identify and retrieve team in the first row
    team_name = row[0].text
    team_agents = Team.where(name: team_name).first.agents
    # Extract the policy values for that team (policies start at 3rd column)
    policy_values_row = row.drop(2)
    # Retrieve the current week and year
    week = Date.parse(date).cweek
    year = Date.parse(date).year
    # Now iterate over each value to ensure the matching
    i = 0
    policy_headers.each do |p|
      # Retrieve the policy
      policy_name_from_header = p.text
      policy = Policy.where(name: policy_name_from_header).first
      # Retrieve policy displayed value
      policy_value_from_table = policy_values_row[i].text.match(/\d+/)[0].to_i
      # Retrieve policy computed value
      policy_value_from_method = group_policy_percentage(team_agents, policy, week, year)

      assert_equal policy_value_from_method, policy_value_from_table
      # Iterate to next policy
      i += 1
    end
  end

  test "all values in team table are percentages between 0 and 100%" do
    visit 'reports/company'
    Calculations::RANGE.each do |range_name, range_value|
      page.all("#collapse-teams-table table tbody tr td .label-#{range_name}").each do |item|
         value = item.text
         regex = /\d{1,3}%/
         # Note that value =~ regex returns the index of the element
         # matching the regex. Here the index should always be zero,
         # as for example if we have 1000% the index will be 1.
         assert_equal 0, value =~ regex
      end
    end
  end

  test "contains a table with one row for each company employee" do
    visit 'reports/company'
    select "100", :from => "employeestable_length"
    assert_equal Agent.all.count, page.all("#employeestable tbody tr").count
  end

  # Note: we take the first individual, and will check each value
  test "the individuals table values are the value of scores referred to in the headers" do
    date = '18/09/2016'
    visit "reports/company?date=#{date}"
    # Process headers (policies start at 2nd column)
    score_headers = page.all("#employeestable th").drop(1)
    # Retrieve the information in the first row
    row = page.first("#employeestable tbody tr").all("td")
    # Identify and retrieve individual in the first row
    individual_name = row[0].text
    agent = Agent.where(name: individual_name).first
    # Extract the score values for that team (scores start at 2nd column)
    score_values_row = row.drop(1)
    # Retrieve the current week and year
    week = Date.parse(date).cweek
    year = Date.parse(date).year

    # Retrieve the individual scores values
    scores_from_method = individual_scores_snapshot(agent, week, year)
    week = scores_from_method[:week][:score]
    previous_week = scores_from_method[:previous_week][:score]
    moving_average = scores_from_method[:moving_average][:score]

    # Now iterate over each value and do the comparison
    i = 0
    score_headers.each do |s|
      s_name = s.text
      s_value_from_table = score_values_row[i].text.match(/\d+/)[0].to_i
      if s_name == 'This week'
        assert_equal week, s_value_from_table
      elsif s_name == 'Previous week'
        assert_equal previous_week, s_value_from_table
      elsif s_name == 'Last 4 weeks'
        assert_equal moving_average, s_value_from_table
      else
        assert false
      end
      i += 1
    end
  end

  test "all values in employees table are percentages between 0 and 100%" do
    visit 'reports/company'
    Calculations::RANGE.each do |range_name, range_value|
      page.all("#employeestable tbody tr td .label-#{range_name}").each do |item|
         value = item.text
         regex = /\d{1,3}%/
         # Note that value =~ regex returns the index of the element
         # matching the regex. Here the index should always be zero,
         # as for example if we have 1000% the index will be 1.
         assert_equal 0, value =~ regex
      end
    end
  end
end

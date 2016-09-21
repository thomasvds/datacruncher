require 'test_helper'
include Calculations::Groups::Policies
# Note that Calculations::Utilities needs to be included as it is used in
# the Policies submodules
include Calculations::Utilities

# To run this specific test only, run:
# rake test TEST=test/modules/calculations_policies_test.rb

class CalculationsPoliciesTest < ActiveSupport::TestCase

  def setup
    @week = 32
    @year = 2016
    @agent = Agent.create(name: "John Doe")
    @agent_2 = Agent.create(name: "Smith Anderson")
    @policy = Policy.create(name: "No work on weekends", timeframe: "on weekends", adverb: "at all")
    @setting = PolicySetting.create(policy: @policy, weight: 0.5, enabled: true)
    @disabled_policy = Policy.create(name: "disabled", timeframe: "on weekends", adverb: "at all")
    @disabled_setting = PolicySetting.create(policy: @disabled_policy, weight: 0.5, enabled: false)
    @check = PolicyCheck.create(agent: @agent, policy: @policy, week: @week, year: @year, enforced: true)
    @check_2 = PolicyCheck.create(agent: @agent_2, policy: @policy, week: @week, year: @year, enforced: false)
  end

  test "group_policy_percentage raises an error if agents contains zero agents" do
    assert_raise ArgumentError do
      group_policy_percentage([], @week, @year)
    end
  end

  test "group_policy_percentage raises an error if agents is a single agent not part of a collection" do
    assert_raise ArgumentError do
      group_policy_percentage(@agent, @week, @year)
    end
  end

  test "group_policy_percentage returns the proportion of policies enforced" do
    assert group_policy_percentage(Agent.all, @policy, @week, @year), 50
  end

  test "all_policies_weekly_percentage_overview raises an error if agents contains zero agents" do
    assert_raise ArgumentError do
      all_policies_weekly_percentage_overview([], @week, @year)
    end
  end

  test "all_policies_weekly_percentage_overview accepts single agents" do
    assert_nothing_raised do
      all_policies_weekly_percentage_overview(@agent, @week, @year)
    end
  end

  test "all_policies_weekly_percentage_overview accepts multiple agents" do
    assert_nothing_raised do
      all_policies_weekly_percentage_overview(Agent.all, @week, @year)
    end
  end

  test "all_policies_weekly_percentage_overview returns an array of hashes" do
    assert_instance_of Array, all_policies_weekly_percentage_overview(@agent, @week, @year)
    assert_instance_of Hash, all_policies_weekly_percentage_overview(@agent, @week, @year)[0]
  end

  test "all_policies_weekly_percentage_overview returns as many hashes as there exist enabled policies" do
    assert_equal Policy.enabled.count, all_policies_weekly_percentage_overview(@agent, @week, @year).count
  end

  test "all_policies_weekly_percentage_overview returns hashes that contain name, weight, value, and range of policies" do
    result = all_policies_weekly_percentage_overview(@agent, @week, @year)[0]
    assert_includes result, :weight
    assert_includes result, :name
    assert_includes result, :value
    assert_includes result, :range
  end
end

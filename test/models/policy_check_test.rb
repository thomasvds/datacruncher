require 'test_helper'

class PolicyCheckTest < ActiveSupport::TestCase
  def setup
    @policy = Policy.new(name: "Random policy")
    @agent = Agent.new(name: "Sophia")
    @week = 11
    @year = 2015
    @params = { policy: @policy, agent: @agent, week: @week, year: @year }
  end

  test "policy_check has a week attribute" do
    @params[:week] = nil
    policy_check = PolicyCheck.create(@params)
    assert_includes policy_check.errors.messages[:week], "can't be blank"
  end

  test "policy_check has a year attribute" do
    @params[:year] = nil
    policy_check = PolicyCheck.create(@params)
    assert_includes policy_check.errors.messages[:year], "can't be blank"
  end

  test "policy_check belongs to a policy" do
    @params[:policy] = nil
    policy_check = PolicyCheck.create(@params)
    assert_includes policy_check.errors.messages[:policy], "can't be blank"
  end

  test "policy_check belongs to an agent" do
    @params[:agent] = nil
    policy_check = PolicyCheck.create(@params)
    assert_includes policy_check.errors.messages[:agent], "can't be blank"
  end

  test "policy_check is valid" do
    policy_check = PolicyCheck.create(@params)
    assert policy_check.valid?
  end
end

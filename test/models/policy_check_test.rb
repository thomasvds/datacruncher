require 'test_helper'

class PolicyCheckTest < ActiveSupport::TestCase
  def setup
    @policy = Policy.new(name: "Test policy")
    @agent = Agent.new(name: "Sophia")
    @week = 11
    @year = 2015
    @params = { policy: @policy, agent: @agent, week: @week, year: @year }
  end

  test "policy_check validates presence of week" do
    @params[:week] = nil
    policy_check = PolicyCheck.create(@params)
    assert_includes policy_check.errors.messages[:week], "can't be blank"
  end

  test "policy_check validates presence of year" do
    @params[:year] = nil
    policy_check = PolicyCheck.create(@params)
    assert_includes policy_check.errors.messages[:year], "can't be blank"
  end

  test "policy_check validates presence of a policy (belongs_to)" do
    @params[:policy] = nil
    policy_check = PolicyCheck.create(@params)
    assert_includes policy_check.errors.messages[:policy], "can't be blank"
  end

  test "policy_check validates presence of an agent" do
    @params[:agent] = nil
    policy_check = PolicyCheck.create(@params)
    assert_includes policy_check.errors.messages[:agent], "can't be blank"
  end

  test "policy_check is invalid when invalid param" do
    @params.merge!(invalid_key: nil)
    assert_raises(ActiveRecord::UnknownAttributeError) { PolicyCheck.create(@params) }
  end

  test "policy_check is valid when valid params" do
    assert_nothing_raised { PolicyCheck.create(@params) }
    puts "  => params which have been tested: #{@params.keys}"
  end
end

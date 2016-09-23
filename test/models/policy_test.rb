require 'test_helper'

class PolicyTest < ActiveSupport::TestCase
  def setup
    @name = "Random policy name"
    @params = { name: @name }
    @enabled_policy = Policy.create(@params)
    @disabled_policy = Policy.create(@params)
    PolicySetting.create(policy: @enabled_policy, enabled: true)
    PolicySetting.create(policy: @disabled_policy, enabled: false)
  end

  # == Validations ==========================================================

  test "policy validates presence of name" do
    @params[:name] = nil
    policy = Policy.create(@params)
    assert_includes policy.errors.messages[:name], "can't be blank"
  end

  test "policy is invalid when invalid param" do
    @params.merge!(invalid_key: nil)
    assert_raises(ActiveRecord::UnknownAttributeError) { Policy.create(@params) }
  end

  test "policy is valid when valid params" do
    assert_nothing_raised { Policy.create(@params) }
    puts "  => params which have been tested: #{@params.keys}"
  end

  # == Class Methods =====================================================

  test "self.enabled to return all and only all enabled policies" do
    assert_equal Policy.enabled.count, 1
    assert_includes Policy.enabled, @enabled_policy
    assert_not_includes Policy.enabled, @disabled_policy
  end

  # == Instance Methods =====================================================

  test "enabled? checks whether policy enabled" do
    assert_equal @enabled_policy.policy_setting.enabled?, true
    assert_not_equal @disabled_policy.policy_setting.enabled?, true
  end
end

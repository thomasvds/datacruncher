require 'test_helper'

class PolicyTest < ActiveSupport::TestCase
  def setup
    @name = "Random policy name"
    @params = { name: @name }
  end

  test "policy validates presence of name" do
    @params[:name] = nil
    policy = Policy.create(@params)
    assert_includes policy.errors.messages[:name], "can't be blank"
  end

  test "policy is valid" do
    policy = Policy.create(@params)
    assert policy.valid?
  end
end

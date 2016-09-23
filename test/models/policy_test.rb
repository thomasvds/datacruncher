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

  test "policy is invalid when invalid param" do
    @params.merge!(invalid_key: nil)
    assert_raises(ActiveRecord::UnknownAttributeError) { Policy.create(@params) }
  end

  test "policy is valid when valid params" do
    assert_nothing_raised { Policy.create(@params) }
    puts "  => params which have been tested: #{@params.keys}"
  end
end

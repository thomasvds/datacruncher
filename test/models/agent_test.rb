require 'test_helper'

class AgentTest < ActiveSupport::TestCase
  def setup
    @name = "Sophia"
    @params = { name: @name }
  end

  test "agent validates presence of name" do
    @params[:name] = nil
    agent = Agent.create(@params)
    assert_includes agent.errors.messages[:name], "can't be blank"
  end

  test "info_hash returns hash with name, id, position and picture_url" do
    agent = Agent.create(@params)
    result = agent.info_hash
    assert_includes result, :name
    assert_includes result, :id
    assert_includes result, :position
    assert_includes result, :picture_url
  end

  test "agent is invalid when invalid param" do
    @params.merge!(invalid_key: nil)
    assert_raises(ActiveRecord::UnknownAttributeError) { Agent.create(@params) }
  end

  test "agent is valid when valid params" do
    assert_nothing_raised { Agent.create(@params) }
    puts "  => params which have been tested: #{@params.keys}"
  end
end

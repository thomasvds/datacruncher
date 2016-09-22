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

  test "agent is valid" do
    agent = Agent.create(@params)
    assert agent.valid?
  end
end

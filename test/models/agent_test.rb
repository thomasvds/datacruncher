require 'test_helper'

class AgentTest < ActiveSupport::TestCase
  def setup
    @agent = Agent.new
    @agent.name = agents(:sophia).name
  end

  test "agent has a name attribute" do
    assert_not @agent.name.nil?, "missing attribute: agent has no name"
  end

  test "agent is valid" do
    assert @agent.valid?, "validation error: agent is not valid"
  end
end

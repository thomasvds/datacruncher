require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @agent = Agent.create(name: "Sophia")
    @params = { agent: @agent }
  end

  test "event has to be associated with an agent" do
    @params[:agent] = nil
    event = Event.create(@params)
    assert_includes event.errors.messages[:agent], "can't be blank"
  end

  test "event is valid" do
    event = Event.create(@params)
    assert event.valid?
  end
end

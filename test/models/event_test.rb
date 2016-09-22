require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @event = Event.new
    @event.agent = agents(:sophia)
  end

  test "event has to be associated with an agent" do
    assert_not @event.nil?, "missing association: event has no agent"
  end

  test "event is valid" do
    assert @event.valid?, "validation error: event is not valid"
  end
end

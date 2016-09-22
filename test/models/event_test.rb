require 'test_helper'

class EventTest < ActiveSupport::TestCase
  test "event is valid to be saved to database" do
    event = Event.new
    # event.date = DateTime.now
    assert_not event.date == nil, "Event had no date attribute"
    assert event.valid?, "Event is invalid"
  end
end

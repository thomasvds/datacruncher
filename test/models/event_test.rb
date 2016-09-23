require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @agent = Agent.create(name: "Sophia")
    @category = Event::CATEGORIES.sample
    @date = "2016-07-04"
    @hour = 18
    @later_hour = 20
    @params = { agent: @agent, category: @category, date: @date, hour: @hour }
    @event = Event.create(@params)
    @params[:hour] = @later_hour
    @event_later_hour = Event.create(@params)
    @date2 = "2016-07-05"
    @date3 = "2016-07-06"
    @date_range = [@date, @date2, @date3]
  end

  # == Class Methods =======================================================

  test "self.last_event_of_day returns an event instance" do
    event = Event.last_event_of_day(@agent, @category, @date)
    assert_instance_of Event, event
  end

  test "self.last_event_of_day returns the last event at the last hour" do
    event = Event.last_event_of_day(@agent, @category, @date)
    assert_equal @event_later_hour.hour, event.hour
    assert_not_equal @event.hour, event.hour
  end

  test "self.hour_of_last_event_by_date returns a hash" do
    @event = Event.hour_of_last_event_by_date(@agent, @date_range)
    assert_instance_of Hash, @event
  end

  test "self.hour_of_last_event_by_date returns hash keys as CATEGORIES" do
    @event = Event.hour_of_last_event_by_date(@agent, @date_range)
    assert_includes Event::CATEGORIES, @event.keys[0]
  end

  # == Validations ==========================================================

  test "event validates presence of an agent" do
    @params[:agent] = nil
    event = Event.create(@params)
    assert_includes event.errors.messages[:agent], "can't be blank"
  end

  test "event is invalid when invalid param" do
    @params.merge!(invalid_key: nil)
    assert_raises(ActiveRecord::UnknownAttributeError) { Event.create(@params) }
  end

  test "event is valid when valid params" do
    assert_nothing_raised { Event.create(@params) }
    puts "  => params which have been tested: #{@params.keys}"
  end
end

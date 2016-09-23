require 'test_helper'

class EventTest < ActiveSupport::TestCase
  def setup
    @agent = Agent.create(name: "Sophia")
    @params = { agent: @agent }
  end

  # == Class Methods =======================================================


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

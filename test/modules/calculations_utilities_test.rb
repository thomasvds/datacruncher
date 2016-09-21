require 'test_helper'
include Calculations::Utilities

# To run this specific test only, run:
# rake test TEST=test/modules/calculations_utilities_test.rb

class CalculationsUtilitiesTest < ActiveSupport::TestCase
  test "trend returns 'up' if increasing trend, with 2 positives" do
    before = 1
    after = 2
    assert_equal 'up', trend(before, after)
  end

  test "trend returns 'up' if increasing trend, with 2 negatives" do
    before = -2
    after = -1
    assert_equal 'up', trend(before, after)
  end

  test "trend returns 'up' if increasing trend, with 1 negative and 1 positive" do
    before = -1
    after = 1
    assert_equal 'up', trend(before, after)
  end

  test "trend returns 'up' if increasing trend, with 1 zero and 1 positive" do
    before = 0
    after = 1
    assert_equal 'up', trend(before, after)
  end

  test "trend returns 'up' if increasing trend, with 1 negative and 1 zero" do
    before = -1
    after = 0
    assert_equal 'up', trend(before, after)
  end

  test "trend returns 'down' if decreasing trend, with 2 positives" do
    before = 1
    after = 0
    assert_equal 'down', trend(before, after)
  end

  test "trend returns 'down' if decreasing trend, with 2 negatives" do
    before = -1
    after = -2
    assert_equal 'down', trend(before, after)
  end

  test "trend returns 'down' if decreasing trend, with 1 negative and 1 positive" do
    before = 1
    after = -1
    assert_equal 'down', trend(before, after)
  end

  test "trend returns 'down' if decreasing trend, with 1 zero and 1 negative" do
    before = 0
    after = -1
    assert_equal 'down', trend(before, after)
  end

  test "trend returns 'down' if decreasing trend, with 1 positive and 1 zero" do
    before = 1
    after = 0
    assert_equal 'down', trend(before, after)
  end

  test "trend returns 'right' if flat trend, with 2 positives" do
    before = 1
    after = 1
    assert_equal 'right', trend(before, after)
  end

  test "trend returns 'right' if flat trend, with 2 negatives" do
    before = -1
    after = -1
    assert_equal 'right', trend(before, after)
  end

  test "trend returns 'right' if flat trend, with 2 zeros" do
    before = 0
    after = 0
    assert_equal 'right', trend(before, after)
  end

  test "range raises an exception for negative value" do
    value = -1
    assert_raises ArgumentError do
      value_range(value)
    end
  end

  test "range raises an exception for value above 100" do
    value = 101
    assert_raises ArgumentError do
      value_range(value)
    end
  end

  test "range returns 'great' for value of 81" do
    value = 81
    assert_equal 'great', value_range(value)
  end

  test "range returns 'great' for value of 100" do
    value = 100
    assert_equal 'great', value_range(value)
  end

  test "range returns 'great' for a random value between 82 and 99 included" do
    value = 82 + rand(18)
    assert_equal 'great', value_range(value)
  end

  test "range returns 'good' for value of 61" do
    value = 61
    assert_equal 'good', value_range(value)
  end

  test "range returns 'good' for value of 80" do
    value = 80
    assert_equal 'good', value_range(value)
  end

  test "range returns 'good' for a random value between 62 and 79 included" do
    value = 62 + rand(18)
    assert_equal 'good', value_range(value)
  end

  test "range returns 'warning' for value of 41" do
    value = 41
    assert_equal 'warning', value_range(value)
  end

  test "range returns 'warning' for value of 60" do
    value = 60
    assert_equal 'warning', value_range(value)
  end

  test "range returns 'warning' for a random value between 42 and 59 included" do
    value = 42 + rand(18)
    assert_equal 'warning', value_range(value)
  end

  test "range returns 'danger' for value of 0" do
    value = 0
    assert_equal 'danger', value_range(value)
  end

  test "range returns 'danger' for value of 40" do
    value = 40
    assert_equal 'danger', value_range(value)
  end

  test "range returns 'danger' for a random value between 1 and 39 included" do
    value = 1 + rand(39)
    assert_equal 'danger', value_range(value)
  end

end


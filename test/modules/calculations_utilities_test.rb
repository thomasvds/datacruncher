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

  RANGE = {
    'great' => 81..100,
    'good' => 61..80,
    'warning' => 41..60,
    'danger' => 0..40
  }

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

end


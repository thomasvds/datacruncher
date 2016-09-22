require 'test_helper'

# To run this specific test only, run:
# rake test TEST=test/integration/about_test.rb

class AboutTest < ActionDispatch::IntegrationTest
  test "loads correctly" do
    visit 'pages/about'
    assert_equal 200 , page.status_code
    assert page.has_content?("about")
  end
end

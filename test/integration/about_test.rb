require 'test_helper'

class AboutTest < ActionDispatch::IntegrationTest
  test "loads correctly" do
    visit 'pages/about'
    assert_equal 200 , page.status_code
    assert page.has_content?("about")
  end
end

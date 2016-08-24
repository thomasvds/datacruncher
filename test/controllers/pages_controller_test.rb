require 'test_helper'

class PagesControllerTest < ActionController::TestCase
  test "should get employee_info" do
    get :employee_info
    assert_response :success
  end

  test "should get employer_info" do
    get :employer_info
    assert_response :success
  end

  test "should get about" do
    get :about
    assert_response :success
  end

end

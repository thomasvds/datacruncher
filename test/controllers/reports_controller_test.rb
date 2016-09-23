require 'test_helper'

# To run this specific test only, run:
# rake test TEST=test/controllers/reports_controller_test.rb

class ReportsController < ActionDispatch::IntegrationTest
  test "data renders json" do
    get '/reports/data', :format => :json
    p JSON.parse(response.body)
  end
end

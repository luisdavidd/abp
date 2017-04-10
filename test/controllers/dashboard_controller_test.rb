require 'test_helper'

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "should get panel" do
    get dashboard_panel_url
    assert_response :success
  end

end

require 'test_helper'

class TeacherControllerTest < ActionDispatch::IntegrationTest
  test "should get panel" do
    get teacher_panel_url
    assert_response :success
  end

end

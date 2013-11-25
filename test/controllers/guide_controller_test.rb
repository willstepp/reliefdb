require 'test_helper'

class GuideControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get results" do
    get :results
    assert_response :success
  end

  test "should get map" do
    get :map
    assert_response :success
  end

  test "should get search" do
    get :search
    assert_response :success
  end

end

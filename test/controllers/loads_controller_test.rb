require 'test_helper'

class LoadsControllerTest < ActionController::TestCase
  setup do
    @load = loads(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:loads)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create load" do
    assert_difference('Load.count') do
      post :create, load: { description: @load.description, stock: @load.stock }
    end

    assert_redirected_to load_path(assigns(:load))
  end

  test "should show load" do
    get :show, id: @load
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @load
    assert_response :success
  end

  test "should update load" do
    patch :update, id: @load, load: { description: @load.description, stock: @load.stock }
    assert_redirected_to load_path(assigns(:load))
  end

  test "should destroy load" do
    assert_difference('Load.count', -1) do
      delete :destroy, id: @load
    end

    assert_redirected_to loads_path
  end
end

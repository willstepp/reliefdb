require File.dirname(__FILE__) + '/../test_helper'
require 'shelters_controller'

# Re-raise errors caught by the controller.
class SheltersController; def rescue_action(e) raise e end; end

class SheltersControllerTest < Test::Unit::TestCase
  fixtures :shelters

  def setup
    @controller = SheltersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:shelters)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:shelter)
    assert assigns(:shelter).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:shelter)
  end

  def test_create
    num_shelters = Shelter.count

    post :create, :shelter => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_shelters + 1, Shelter.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:shelter)
    assert assigns(:shelter).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Shelter.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Shelter.find(1)
    }
  end
end

require File.dirname(__FILE__) + '/../test_helper'
require 'resources_controller'

# Re-raise errors caught by the controller.
class ResourcesController; def rescue_action(e) raise e end; end

class ResourcesControllerTest < Test::Unit::TestCase
  fixtures :resources

  def setup
    @controller = ResourcesController.new
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

    assert_not_nil assigns(:resources)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:resource)
    assert assigns(:resource).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:resource)
  end

  def test_create
    num_resources = Resource.count

    post :create, :resource => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_resources + 1, Resource.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:resource)
    assert assigns(:resource).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil Resource.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Resource.find(1)
    }
  end
end

require File.dirname(__FILE__) + '/../test_helper'
require 'faq_categories_controller'

# Re-raise errors caught by the controller.
class FaqCategoriesController; def rescue_action(e) raise e end; end

class FaqCategoriesControllerTest < Test::Unit::TestCase
  fixtures :faq_categories

  def setup
    @controller = FaqCategoriesController.new
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

    assert_not_nil assigns(:faq_categories)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:faq_category)
    assert assigns(:faq_category).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:faq_category)
  end

  def test_create
    num_faq_categories = FaqCategory.count

    post :create, :faq_category => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_faq_categories + 1, FaqCategory.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:faq_category)
    assert assigns(:faq_category).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil FaqCategory.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      FaqCategory.find(1)
    }
  end
end

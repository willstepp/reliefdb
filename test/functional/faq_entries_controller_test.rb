require File.dirname(__FILE__) + '/../test_helper'
require 'faq_entries_controller'

# Re-raise errors caught by the controller.
class FaqEntriesController; def rescue_action(e) raise e end; end

class FaqEntriesControllerTest < Test::Unit::TestCase
  fixtures :faq_entries

  def setup
    @controller = FaqEntriesController.new
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

    assert_not_nil assigns(:faq_entries)
  end

  def test_show
    get :show, :id => 1

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:faq_entry)
    assert assigns(:faq_entry).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:faq_entry)
  end

  def test_create
    num_faq_entries = FaqEntry.count

    post :create, :faq_entry => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_faq_entries + 1, FaqEntry.count
  end

  def test_edit
    get :edit, :id => 1

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:faq_entry)
    assert assigns(:faq_entry).valid?
  end

  def test_update
    post :update, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1
  end

  def test_destroy
    assert_not_nil FaqEntry.find(1)

    post :destroy, :id => 1
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      FaqEntry.find(1)
    }
  end
end

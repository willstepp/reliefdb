require File.dirname(__FILE__) + '/../test_helper'
require 'quick_controller'

# Re-raise errors caught by the controller.
class QuickController; def rescue_action(e) raise e end; end

class QuickControllerTest < Test::Unit::TestCase
  def setup
    @controller = QuickController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

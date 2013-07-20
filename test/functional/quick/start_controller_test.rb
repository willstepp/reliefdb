require File.dirname(__FILE__) + '/../../test_helper'
require 'quick/start_controller'

# Re-raise errors caught by the controller.
class Quick::StartController; def rescue_action(e) raise e end; end

class Quick::StartControllerTest < Test::Unit::TestCase
  def setup
    @controller = Quick::StartController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

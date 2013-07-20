require File.dirname(__FILE__) + '/../../test_helper'
require 'quick/volunteer_controller'

# Re-raise errors caught by the controller.
class Quick::VolunteerController; def rescue_action(e) raise e end; end

class Quick::VolunteerControllerTest < Test::Unit::TestCase
  def setup
    @controller = Quick::VolunteerController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

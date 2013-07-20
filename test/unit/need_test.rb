require File.dirname(__FILE__) + '/../test_helper'

class NeedTest < Test::Unit::TestCase
  fixtures :needs

  def setup
    @need = Need.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Need,  @need
  end
end

require File.dirname(__FILE__) + '/../test_helper'

class SurplusTest < Test::Unit::TestCase
  fixtures :surplus

  def setup
    @surplus = Surplus.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Surplus,  @surplus
  end
end

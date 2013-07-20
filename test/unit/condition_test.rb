require File.dirname(__FILE__) + '/../test_helper'

class ConditionTest < Test::Unit::TestCase
  fixtures :conditions

  def setup
    @condition = Condition.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Condition,  @condition
  end
end

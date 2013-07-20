require File.dirname(__FILE__) + '/../test_helper'

class HistoryTest < Test::Unit::TestCase
  fixtures :histories

  def setup
    @history = History.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of History,  @history
  end
end

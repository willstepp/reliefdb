require File.dirname(__FILE__) + '/../test_helper'

class LoadTest < Test::Unit::TestCase
  fixtures :loads

  def setup
    @load = Load.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Load,  @load
  end
end

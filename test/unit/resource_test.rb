require File.dirname(__FILE__) + '/../test_helper'

class ResourceTest < Test::Unit::TestCase
  fixtures :resources

  def setup
    @resource = Resource.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Resource,  @resource
  end
end

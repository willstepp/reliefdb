require File.dirname(__FILE__) + '/../test_helper'

class ShelterTest < Test::Unit::TestCase
  fixtures :shelters

  def setup
    @shelter = Shelter.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Shelter,  @shelter
  end
end

require File.dirname(__FILE__) + '/../test_helper'

class ItemTest < Test::Unit::TestCase
  fixtures :items

  def setup
    @item = Item.find(1)
  end

  # Replace this with your real tests.
  def test_truth
    assert_kind_of Item,  @item
  end
end

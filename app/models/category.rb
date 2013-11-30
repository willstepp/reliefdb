class Category < ActiveRecord::Base
  has_paper_trail

  has_and_belongs_to_many :items
  before_destroy :remove_item_associations

  private

  def remove_item_associations
    self.items.destroy_all
  end
end

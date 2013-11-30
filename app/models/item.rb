class Item < ActiveRecord::Base
  has_paper_trail

  has_and_belongs_to_many :categories
  before_destroy :remove_category_associations

  private

  def remove_category_associations
    self.categories.destroy_all
  end
end

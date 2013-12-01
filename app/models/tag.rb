class Tag < ActiveRecord::Base
	has_paper_trail

  has_and_belongs_to_many :resources
  before_destroy :remove_resource_associations

  private

  def remove_resource_associations
    self.resources.destroy_all
  end
end

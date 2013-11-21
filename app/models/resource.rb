class Resource < ActiveRecord::Base
  has_paper_trail

  belongs_to :facility
  belongs_to :load

  has_and_belongs_to_many :items
  before_destroy :remove_item_associations

  def can_manage?(user)
    if user
      user.role?(:admin) or self.facility.organization.users.include?(user)
    else
      false
    end
  end

  private

  def remove_item_associations
    self.items.destroy_all
  end
end

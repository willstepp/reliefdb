class Resource < ActiveRecord::Base
  belongs_to :facility
  belongs_to :load

  has_and_belongs_to_many :categories
  before_destroy :remove_category_associations

  def can_manage?(user)
    if user
      user.role?(:admin) or self.facility.organization.users.include?(user)
    else
      false
    end
  end

  private

  def remove_category_associations
    self.categories.each do |c|
      self.categories.destroy(c)
    end
  end
end

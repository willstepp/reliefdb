class Facility < ActiveRecord::Base
  has_paper_trail

  belongs_to :organization
  
  has_many :resources, :dependent => :destroy
  has_many :loads, :dependent => :destroy

  def can_manage?(user)
    if user
      user.role?(:admin) or self.organization.users.include?(user)
    else
      false
    end
  end
end

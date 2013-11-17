class Organization < ActiveRecord::Base
  has_paper_trail

  has_and_belongs_to_many :users
  before_destroy :remove_user_associations

  has_many :facilities, :dependent => :destroy

  private

  def remove_user_associations
    self.users.each do |u|
      self.users.destroy(u)
    end
  end
end

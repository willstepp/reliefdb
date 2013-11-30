class User < ActiveRecord::Base
  has_paper_trail

  has_and_belongs_to_many :organizations
  before_destroy :remove_organization_associations

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  def role?(name)
    self.roles.nil? ? false : self.roles.include?(name.to_s)
  end

  private

  def remove_organization_associations
    self.organizations.destroy_all
  end
end

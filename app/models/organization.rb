class Organization < ActiveRecord::Base
  has_paper_trail

  has_and_belongs_to_many :users
  has_many :facilities, :dependent => :destroy

  before_create :generate_slug
  before_destroy :remove_user_associations

  validates_presence_of :name

  def self.all_approved
    self.where(:approved => true)
  end

  def self.all_unapproved
    self.where(:approved => false)
  end

  def can_manage?(user)
    if user
      user.role?(:admin) or self.users.include?(user)
    else
      false
    end
  end

  private

  def remove_user_associations
    self.users.destroy_all
  end

  def generate_slug
    if !self.name.blank?
      self.slug = self.name.downcase.strip.delete("^a-zA-Z0-9 ").gsub('  ', '').gsub(' ', '-')
      if Organization.where(:slug => self.slug).first
        self.slug = "#{self.slug}-#{SecureRandom.hex(3)}"
      end
    end
  end
end

class User < ActiveRecord::Base
  has_paper_trail
  
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  def role?(name)
    self.roles.nil? ? false : self.roles.include?(name.to_s)
  end
end

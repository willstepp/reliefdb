class Facility < ActiveRecord::Base
  has_paper_trail

  belongs_to :organization
  
  has_many :resources, :dependent => :destroy
  has_many :loads, :dependent => :destroy
end

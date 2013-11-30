class Load < ActiveRecord::Base
  has_paper_trail

  belongs_to :facility
  has_many :resources
end

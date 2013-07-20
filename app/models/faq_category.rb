class FaqCategory < ActiveRecord::Base
  has_many :faq_entries, :order => 'position'
  acts_as_list
end

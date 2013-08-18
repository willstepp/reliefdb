class FaqCategory < ActiveRecord::Base
  set_primary_key :id 
  has_many :faq_entries, :order => 'position'
end

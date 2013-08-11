class FaqCategory < ActiveRecord::Base
  has_many :faq_entries, :order => 'position'
end

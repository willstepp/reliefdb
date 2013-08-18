class FaqEntry < ActiveRecord::Base
  set_primary_key :id 
  belongs_to :faq_category
end

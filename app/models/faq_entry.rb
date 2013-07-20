class FaqEntry < ActiveRecord::Base
  belongs_to :faq_category
  acts_as_list :scope => :faq_category
end

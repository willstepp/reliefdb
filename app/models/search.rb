class Search < ActiveRecord::Base
  #set_primary_key :id 
  belongs_to :users
  serialize :save_data
end

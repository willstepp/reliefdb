class Search < ActiveRecord::Base
  belongs_to :users
  serialize :save_data
end

class Category < ActiveRecord::Base
  #set_primary_key :id 
  has_and_belongs_to_many :items, :order => "upper(name)"

  validates_presence_of :name
  validates_uniqueness_of :name

  belongs_to :updated_by, :class_name => "User", :foreign_key => "updatedbyid"
  before_update :update_history
  after_create :update_history

  def shelters_that_need
    Shelter.find_by_sql(["SELECT DISTINCT upper(shelters.name), shelters.* FROM shelters, conditions, categories_items ci WHERE ci.category_id = ? AND ci.item_id = conditions.item_id AND conditions.type = 'Need' AND conditions.shelter_id = shelters.id ORDER BY upper(shelters.name)", self.id])
  end

  def self.names_for_select
    (Category.all(:order => 'name').map {|cat| [cat.name,cat.id]}).unshift(["All","All"])
  end

end

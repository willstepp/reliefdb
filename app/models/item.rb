class Item < ActiveRecord::Base
  set_primary_key :id 
  has_and_belongs_to_many :categories, :order => "upper(name)"
  has_many :conditions
  has_many :needs
  has_many :surpluses

  validates_presence_of :name
  validates_presence_of :categories
  validates_uniqueness_of :name

  belongs_to :updated_by, :class_name => "User", :foreign_key => "updatedbyid"
  before_update :update_history
  after_create :update_history

  def self.find_all_with_uncat(cond=nil)
    if cond
      cond = "WHERE " + sanitize_sql(cond)
    else
      cond = ""
    end
    i = Category.find_by_name("New/Unassigned").id
    find_by_sql("SELECT items.*, 
                  (EXISTS (SELECT * FROM categories_items WHERE item_id = items.id
                                                            AND category_id = #{i}) 
                    AND NOT EXISTS (SELECT * FROM categories_items WHERE item_id = items.id
                                                            AND category_id != #{i}))
                  AS uncat,
                  (NOT EXISTS (SELECT * FROM categories_items WHERE item_id = items.id))
                  AS nocat FROM items #{cond} ORDER BY upper(items.name);")
  end

  def self.items_with_counts(category, order)
    Item.find_by_sql ["select items.*,
      (select sum(conditions.qty_needed) 
        from conditions
        where conditions.item_id = items.id
          and conditions.type = 'Need') as tot_needed,
      (select count(*)
        from conditions
        where conditions.item_id = items.id
          and conditions.type = 'Need') as shelters_need
      from categories_items
      join items 
        on items.id = categories_items.item_id
      where category_id = ? order by items.name " + order, category]
  end

  def self.need_counts
    need_qtys = {}
    need_shelters= {}
    ActiveRecord::Base.connection.select_all("SELECT item_id, sum(conditions.qty_needed) FROM conditions WHERE type = 'Need' GROUP BY (item_id);").each {|r| need_qtys[r['item_id'].to_i] = r['sum'] }
    ActiveRecord::Base.connection.select_all("SELECT conditions.item_id, count(shelters.id) FROM conditions, shelters WHERE conditions.type = 'Need' AND conditions.shelter_id = shelters.id GROUP BY (conditions.item_id);").each {|r| need_shelters[r['item_id'].to_i] = r['count'] }
    return [need_qtys, need_shelters]
  end

  def shelters_that_need
    Shelter.find_by_sql(["SELECT DISTINCT upper(shelters.name), shelters.* FROM shelters, conditions WHERE conditions.item_id = ? AND conditions.type = 'Need' AND conditions.shelter_id = shelters.id ORDER BY upper(shelters.name)", self.id])
  end

  def self.items_for_select(category)
    if category == "All"
      [["All","All"]]
    else 
      cat = Category.find(category)
      cat.items.map{|itm|[itm.name,itm.id]}.unshift(["All","All"])
    end    
  end

end

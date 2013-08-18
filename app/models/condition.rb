class Condition < ActiveRecord::Base
  #set_primary_key :id 
  
  belongs_to :shelter
  belongs_to :item
  belongs_to :load

  before_update { |r| raise "Can not modify condition while assigned to load." if r.load_id and not r.oksave }

  belongs_to :updated_by, :class_name => "User", :foreign_key => "updatedbyid"
  before_update :update_history
  after_create :update_history
  
  attr_accessor :can_update
#-----new code below this line----------------------------------

  def self.cols
    ["shelters.name as shelter_name","shelters.organization","shelters.state","shelters.town","shelters.status","shelters.main_phone","shelters.parish","conditions.updated_at","items.name as item_name","conditions.qty_needed","conditions.surplus_individual","conditions.urgency"]
  end
  
  def self.col_names
    ["Name","Org","State","City/Town","Status","Main Phone","County","Last Update","Item","Needed","Available","Urgency"]
  end
  
  def self.col_for_sort
    ["upper(shelters.name)","upper(shelters.organization)","upper(shelters.state)","upper(shelters.town)","shelters.status","shelters.main_phone","shelters.parish","conditions.updated_at","upper(items.name)","conditions.qty_needed","conditions.surplus_individual","conditions.urgency"]
  end
  
  def self.sort_order
    ["ASC","ASC","ASC","ASC","ASC","ASC","ASC","DESC","ASC","ASC","ASC","ASC"]  
  end

  def updated_info
    updated_at.strftime("%Y/%m/%d ") + (ucfn.nil? ? '' : ucfn[0..0] ) + (ucln.nil? ? '' : ucln[0..2])
  end
  
  def can_update(user)
    if user.nil?
      false
    else
      self.shelter.users.collect{|u|u.id}.include?(user.id)      
    end
  end
  
  def need_qty
    if self[:type].to_s != 'Need'
      return nil    
    end
    if qty_needed.nil?
      'Needed'
    else
      qty_needed.to_s + ' ' + (packaged_as.blank? ? "" : "(" + packaged_as + ")")
    end
  end
  def avail_qty
    if self[:type].to_s != 'Surplus'
      return nil    
    end
    if surplus_individual.nil?
      'Avail'
    else
      surplus_individual.to_s + ' ' + (packaged_as.blank? ? "" : "(" + packaged_as + ")")
    end
  end
#-----new code above this line----------------------------------  

  def save_with_load
    @oksave = true
    save
    @oksave = nil
  end

  def oksave
    @oksave
  end

  def name
    item.name + " at " + shelter.name
  end

  COLS = ['Map', 'State', 'Region', 'County', 'Town', 'Org', 'Facility', 'Status', 'Hours', 'Avail', 'Item', 'Urgency', 'Qty', 'Update']

  @@SORTS = {
             "Avail" => "conditions.type DESC",
             "Item" => "catname(items.name)",
             "Facility" => "catname(shelters.name)",
             "Update" => "conditions.updated_at DESC",
             "Urgency" => "conditions.urgency",
             "Distance" => "distance",
             "Qty" => "conditions.surplus_individual DESC, conditions.qty_needed DESC"
            }

  def self.sorts
    Shelter.sorts.reject {|k, v| not COLS.include?(k)}.merge(@@SORTS)
  end

  def self.default_sort_name
    "Avail/State/Town"
  end

  def self.last_sort
    "Item"
  end

  def self.show_conds
    "(load_id IS NULL)"
  end

  def self.condition_conditions(conditions=nil, category=nil, catomit=nil)
    if conditions
      conditions = "WHERE " + sanitize_sql(conditions)
      conditions += " AND conditions.shelter_id = shelters.id AND conditions.item_id = items.id"
    else
      conditions = "WHERE conditions.shelter_id = shelters.id AND conditions.item_id = items.id"
    end
    conditions += " AND #{show_conds}"
    if category
      conditions += " AND items.id = categories_items.item_id AND categories_items.category_id = #{category.id}"
      conditions = ",categories,categories_items " + conditions
    end
    if catomit
      conditions += " AND items.id = categories_items.item_id AND categories_items.category_id NOT IN('15','47')"
      conditions = ",categories_items " + conditions
    end
    return conditions
  end

  def self.count_ids_for(conditions = nil, category = nil,catomit=nil)
    conditions = condition_conditions(conditions, category,catomit)
    ActiveRecord::Base.connection.select_one("SELECT COUNT(*) FROM (SELECT DISTINCT conditions.id FROM conditions,shelters,items #{conditions}) a;")['count'].to_i
  end

  def self.condition_ids_for(conditions = nil, order = nil, limit = nil, offset = nil, category = nil, catomit=nil)
    conditions = condition_conditions(conditions, category,catomit)
    order = "ORDER BY " + sanitize_sql(order) if order
    limit = "LIMIT " + limit.to_i.to_s if limit
    offset = "OFFSET " + offset.to_i.to_s if offset
    if order
      distinct = order.split(/ |,/).delete_if {|s| not s =~ /([a-z]+[(])?[a-z]+[.][a-z]+[)]?/}
      distinct = distinct.push('conditions.id').join(', ')
    else
      distinct = 'conditions.id'
    end
    ActiveRecord::Base.connection.select_all("SELECT DISTINCT ON (#{distinct}) conditions.id FROM conditions,shelters,items #{conditions} #{order} #{limit} #{offset};").map {|r| r['id'].to_i}
  end

end

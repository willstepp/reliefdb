class Load < ActiveRecord::Base
  #set_primary_key :id 
  has_many :conditions
  belongs_to :source, :class_name => "Shelter", :foreign_key => "source_id"
  belongs_to :destination, :class_name => "Shelter", :foreign_key => "destination_id"
  belongs_to :final_destination, :class_name => "Shelter", :foreign_key => "final_destination_id"

  belongs_to :updated_by, :class_name => "User", :foreign_key => "updatedbyid"
  before_update :update_history
  after_create :update_history

  before_destroy :remove_all_conds

  validates_presence_of :title

  COLS = ['Map', 'SrcDst', 'State', 'Region', 'County', 'Town', 'Org', 'Facility', 'Load Desc', 'Status', 'Sched', 'Has Truck', 'Needs WH', 'Update']

  @@SORTS = {
    "Load Desc" => "catname(loads.title)",
    "Facility" => "catname(shelters.name)",
    "Status" => "loads.status",
    "Has Truck" => "loads.transport_avail",
    "Needs WH" => "loads.routing_type DESC",
#    "Next Date" => "nextloaddate(loads.status, loads.ready_by, loads.etd, loads.eta)",
    "Update" => "loads.updated_at DESC",
    "SrcDst" => "(shelters.id = loads.source_id) DESC",
  }

  def self.sorts
    Shelter.sorts.merge(@@SORTS).reject {|k, v| not COLS.include?(k)}
  end

  def self.default_sort_name
    "Update"
  end

  def self.last_sort
    "SrcDst"
  end

  def self.load_conditions(conditions)
    if conditions
      conditions = sanitize_sql(conditions) + " AND "
    end
    conditions = "WHERE #{conditions} (shelters.id = loads.source_id OR shelters.id = loads.destination_id)"
    conditions += " AND loads.status < 1000"
  end

  def self.count_shelter_ids_for(conditions = nil)
    conditions = load_conditions(conditions)
    ActiveRecord::Base.connection.select_one("SELECT COUNT(*) FROM shelters, loads #{conditions}")['count'].to_i
  end

  def self.shelter_records_for(conditions = nil, order = nil)
    conditions = load_conditions(conditions)
    order = "ORDER BY " + sanitize_sql(order) if order
    ActiveRecord::Base.connection.select_all("SELECT shelters.id AS shelterid, loads.id AS loadid, (shelters.id = loads.source_id) AS is_source 
                                             FROM shelters, loads #{conditions} #{order}")
  end

  class Status < ColoredLevelSetting
    @levels = { -20 => "Rejected", -10 => "Problem", 0 => "Offered", 10 => "Accepted/Committed", 20 => "Ready To Ship", 30 => "En Route", 40 => "Arrived", 50 => "Unloaded", 1010 => "Done", 1020 => "Cancelled" }
    @colors = { -20 => "#DD4444", -10 => "#DD0000", 0 => "#DD44DD", 10 => "#DDDD00", 20 => "#00DD00", 30=> "#00DDDD", 40=> "#0088EE", 50 => "#8888FF" }
  end

  def status
    Status.new(read_attribute("status"))
  end

  class RoutingType < LevelSetting
    @levels = { 0 => "No", 1 => "Yes" }
  end

  def routing_type
    RoutingType.new(read_attribute("routing_type"))
  end

  def next_src_date
    case status
    when 0, 10
      ready_by && "Ready: #{ready_by.month}/#{ready_by.mday}"
    when 20
      etd && "Leave: #{etd.month}/#{etd.mday}"
    else
      nil
    end
  end
  def next_dst_date
    if status.to_i < 40
      eta && "Arrive: #{eta.month}/#{eta.mday}"
    end
  end

  def updated_txt
    "#{updated_at.month}/#{updated_at.mday}"
  end

  def move_to_status(user, newstat)
    transaction do
      case newstat
      when -20,0
        free_needs
      when 10
        grab_needs(user)
      when 1010
        destroy_all_conds
      when 1020
        remove_all_conds
      end
      self.status = newstat
      set_updated_by user
      save
    end
  end

  def allowed_next_statuses(user)
    src = source.allowed_write?(user)
    dst = destination.allowed_write?(user)
    if src && dst
      who = :both
    elsif src
      who = :src
    elsif dst
      who = :dst
    else
      return []
    end
    return available_next_statuses(who)
  end
    
  def available_next_statuses(who)
    case who
    when :both
      Set.new(available_next_statuses(:src) + available_next_statuses(:dst)).sort
    when :src
      case status
      when -20
        [0, 1020]
      when -10
        previous = History.find_by_objtype_and_objid('Load', id, :order => 'id DESC', :limit => 1, :offset => 1)
        if previous and previous.obj and [10,20,30,40].include?(previous.obj.status.to_i)
          [previous.obj.status.to_i, 0, 1020]
        else
          [0, 1020]
        end
      when 0
        [1020]
      when 10
        [20, 0, -10, 1020]
      when 20
        [30, 0, -10, 1020]
      when 30
        [-10]
      when 40
        [-10]
      when 50
        [1010]
      else
        []
      end
    when :dst
      case status
      when -20
        [10]
      when 0
        if routing_type == 0
          [10, -20]
        else
          [-20]
        end
      when 10, 20
        [-20]
      when 30
        [40, -10]
      when 40
        [50, -10]
      else
        []
      end
    end
  end


  def bgcolor
    status.bgcolor
  end

  class TransportAvail < LevelSetting
    @levels = { 0 => "No", 1 => "Unknown", 2=> "Yes" }
  end

  def transport_avail
    TransportAvail.new(read_attribute("transport_avail"))
  end

#  def ready_by
#    dt = read_attribute("ready_by") and dt.ctime
#  end
#  def etd
#    dt = read_attribute("etd") and dt.ctime
#  end
#  def eta
#    dt = read_attribute("eta") and dt.ctime
#  end
  def set_date_field(field, dt)
    if dt and dt.kind_of?(Time)
      return write_attribute(field, dt) 
    elsif dt and dt != ''
      begin
        return write_attribute(field, Time.parse(dt, true))
      rescue
        err = " -- Invalid Date/Time format. Try using a format like '12/25/05 4:53PM' or just '12/25/05'."
        errors.add(field, err)
        raise ErrorAddedOnAttributeAssignment, err
      end
    else
      return write_attribute(field, nil)
    end
  end
  def ready_by=(dt)
    set_date_field("ready_by", dt)
  end
  def etd=(dt)
    set_date_field("etd", dt)
  end
  def eta=(dt)
    set_date_field("eta", dt)
  end

  def truck_reg=(str)
    write_attribute("truck_reg", str.gsub("/", "_"))
  end

  def items_ary
    items = Set.new(Item.find_by_sql("SELECT DISTINCT items.* FROM conditions src, conditions dst, items
                                WHERE items.id = src.item_id AND src.type = 'Surplus'
                                  AND items.id = dst.item_id AND dst.type = 'Need'
                                  AND src.shelter_id = #{source.id} AND dst.shelter_id = #{destination.id}
                                  AND (src.load_id = #{id || -1} OR src.load_id IS NULL)
                                  AND (dst.load_id = #{id || -1} OR dst.load_id IS NULL)
    ;"))
    ary = []
    items.each do |item|
      h = {}
      h[:item] = item
      h[:have] = ActiveRecord::Base.connection.select_one("SELECT sum(surplus_individual) FROM conditions
                                                      WHERE item_id = #{item.id}
                                                        AND shelter_id = #{source.id}
                                                        AND load_id IS NULL
                                                        AND type = 'Surplus';")['sum'].to_i
      h[:sending] = id && ActiveRecord::Base.connection.select_one("SELECT sum(surplus_individual) FROM conditions
                                                         WHERE item_id = #{item.id}
                                                           AND shelter_id = #{source.id}
                                                           AND load_id = #{id}
                                                           AND type = 'Surplus';")['sum'].to_i
      h[:have] += h[:sending].to_i
      h[:needed] = ActiveRecord::Base.connection.select_one("SELECT sum(qty_needed) FROM conditions
                                                           WHERE item_id = #{item.id}
                                                             AND shelter_id = #{destination.id}
                                                             AND load_id IS NULL
                                                             AND type = 'Need';")['sum'].to_i 
      h[:accepted] = id && ActiveRecord::Base.connection.select_one("SELECT sum(qty_needed) FROM conditions
                                                           WHERE item_id = #{item.id}
                                                             AND shelter_id = #{destination.id}
                                                             AND load_id = #{id}
                                                             AND type = 'Need';")['sum'].to_i 
      h[:needed] += h[:accepted].to_i
      ary << h
    end
    return ary
  end

  def offer
    return @offer if @offer
    @offer = {}
    items_ary.each {|h| @offer[h[:item].id] = h[:sending] }
    return @offer
  end

  def update_sending(user, itemhash)
    if status == 0
      transaction do
        update_quantities(user, itemhash, source, Surplus)
      end
    else
      raise "Load must be in state 'Offerred' to change quantities."
    end
  end

  def accept_with_sending(user, sending)
    if allowed_next_statuses(user).include?(10)
      transaction do
        self.status = 10
        set_updated_by user
        save
        grab_needs(user, sending)
      end
    else
      raise "Accept attempted when not allowed to move to that state."
    end
  end

  private # These do no security checks!!!
  def update_quantities(user, itemhash, fac, ctype)
    old = {}
    conditions.each do |c|
      if c.class == ctype
        i = c.item_id
        if old[i]
          raise "Error: corrupt load, multiple entries for item. Please delete and start over."
        elsif c.shelter_id == fac.id
          old[i] = c
        end
      end
    end
    donecond = []
#    breakpoint
    itemhash.each do |itemid, qty|
      itemid = itemid.to_i
      qty = qty.to_i
      next if qty == 0 # Old will be freed at end, absent from donecond
      cond = old[itemid]
      if cond
        if cond.qty == qty
          # No change
        else
          cond = find_qty(user, itemid, ctype, fac, qty, cond)
        end
      else 
        cond = find_qty(user, itemid, ctype, fac, qty)
      end 
      donecond << cond
    end # each item
#    breakpoint
    conditions.each do |c|
      if c.shelter_id == fac.id and not donecond.include?(c)
        ActiveRecord::Base.connection.update("UPDATE conditions SET load_id = NULL WHERE id = #{c.id}")
        logger.info("Removed load #{id} from condition #{c.id}")
      elsif not [source.id, destination.id].include?(c.shelter_id)
        ActiveRecord::Base.connection.update("UPDATE conditions SET load_id = NULL WHERE id = #{c.id}")
        logger.error("Error: Removed rogue load #{id} from condition #{c.id}")
      end
    end
#    breakpoint
  end

  def find_qty(user, itemid, ctype, fac, qty, mysrc = nil)
    if mysrc and mysrc.qty >= qty
      return take_qty(user, qty, mysrc)
    elsif mysrc
      qtyremain = qty - mysrc.qty
    else
      qtyremain = qty
    end
    srcs = ctype.find_by_sql("SELECT * FROM conditions
                                WHERE type = '#{ctype}'
                                  AND shelter_id = #{fac.id}
                                  AND item_id = #{itemid}
                                  AND load_id IS NULL
                                ORDER BY surplus_individual, qty_needed
                             ;")
    if srcs
      srcs.each do |src|
        if not mysrc
          if src.qty >= qty
            return take_qty(user, qty, src)
          else
            mysrc = src
            qtyremain -= mysrc.qty
            next
          end
        end
        if src.qty >= qtyremain
          src.qty -= qtyremain
          qtyremain = 0
          src.set_updated_by user
          src.save_with_load
          break
        else
          qtyremain -= src.qty
          src.qty = 0
          src.set_updated_by user
          src.save_with_load
        end
      end
    end
    if not mysrc
      return nil
    end
    if ctype == Need
      mysrc.qty = qty - qtyremain
    else
      # As a convenience, allow to adjust up surplus even if don't have
      mysrc.qty = qty
    end
    mysrc.load = self
    mysrc.set_updated_by user
    mysrc.save_with_load
    return mysrc
  end

  # This should only be called if src has at least enough
  def take_qty(user, qty, src)
    if src.qty > qty
      extra = src.clone
      extra.load = nil
      extra.qty = src.qty - qty
      extra.set_updated_by user
      extra.save_with_load
    end
    src.qty = qty
    src.load = self
    src.set_updated_by user
    src.save_with_load
    return src
  end

  def self.will_send(sending, needed)
    if needed
      [sending, needed].min
    else
      sending
    end
  end

  def grab_needs(user, sending=nil)
    origneeds = ActiveRecord::Base.connection.select_all("SELECT item_id, sum(qty_needed) FROM conditions
                                                            WHERE shelter_id = #{destination.id}
                                                              AND conditions.type = 'Need'
                                                            GROUP BY item_id
                                                            ORDER BY item_id");
    if not sending
      sending = {}
      items_ary.each do |h|
        sending[h[:item].id] = Load.will_send(h[:sending], h[:needed])
      end
    end
    fac = destination
    ctype = Need
    update_quantities(user, sending, fac, ctype)
    fac = source
    ctype = Surplus
    update_quantities(user, sending, fac, ctype)
    finalneeds = ActiveRecord::Base.connection.select_all("SELECT item_id, sum(qty_needed) FROM conditions
                                                            WHERE shelter_id = #{destination.id}
                                                              AND conditions.type = 'Need'
                                                            GROUP BY item_id
                                                            ORDER BY item_id");
    if finalneeds != origneeds
      # This should be invariant; we never want to mess up how much in total you need
      raise "Error: Need quantities miscalculated during load assignment. If you see this message, you didn't do anything wrong, it's a bug! Please report it."
    end
  end

  def free_needs
    ActiveRecord::Base.connection.update("UPDATE conditions SET load_id = NULL WHERE load_id = #{id} AND type = 'Need'")
  end

  def remove_all_conds
    ActiveRecord::Base.connection.update("UPDATE conditions SET load_id = NULL WHERE load_id = #{id}")
  end

  def destroy_all_conds
    Condition.delete_all("load_id = #{id} AND (shelter_id = #{source.id} OR shelter_id = #{destination.id})")
  end

end

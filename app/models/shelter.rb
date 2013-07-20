require 'geocode'
require 'uri'

class ::DateTime
	alias_method :to_s, :to_formatted_s
end

class Shelter < ActiveRecord::Base
  has_many :conditions
  has_many :needs, :order => "urgency"
  has_many :surpluses, :class_name => "Surplus"
  alias surplus surpluses
  has_and_belongs_to_many :resources, :order => 'catname(kind), catname(name)'
  has_and_belongs_to_many :users
  has_many :projects,
           :select => "*,(select count(*) from tasks where tasks.project_id = projects.id) as tasks_cntr,(select count(*) from tasks where tasks.project_id = projects.id and tasks.done = true) as done_cntr"

  validates_presence_of :name

  before_save :update_address

  belongs_to :cond_updated_by, :class_name => "User", :foreign_key => "cond_updated_by_id"
  belongs_to :updated_by, :class_name => "User", :foreign_key => "updated_by_id"
  before_update :update_history
  after_create :update_history

  before_create :set_def_cupd
  
  validates_presence_of :client_contact_name, 
                        :if => :has_client_contact_info?,
                        :message => 'Client Contact Name Must Be Entered'
  validates_numericality_of :waiting_list, :allow_nil => true
  validates_inclusion_of :waiting_list, :in => 0..104, :allow_nil => true
  validates_presence_of :fee_amount, 
                        :if => :fee_is_required?,
                        :message => "Fee Required Must Be Entered"
                        
  @@SORTS = {
             "Region" => "catname(shelters.region)",
             "Town" => "catname(shelters.town)",
             "County" => "catname(shelters.parish)",
             "Org" => "catname(shelters.organization)",
             "State" => "catname(shelters.state)",
             "Type" => "catname(shelters.facility_type)",
             "Name" => "catname(shelters.name)",
             "Address" => "catname(shelters.address)",
             "Hours" => "catname(shelters.hours)",
             "DC?" => "shelters.dc DESC",
             "Main Phone" => "catname(shelters.main_phone)",
             "Status" => "shelters.status",
             "Cond Upd" => "shelters.cond_updated_at DESC",
             "Update" => "shelters.updated_at DESC",
            }
#-----new code below this line---------------------------------
  def updated_info
    updated_at.strftime("%Y/%m/%d") + ' ' + self.updated_by.initials
  end
  
  def conditions_updated_info
    cond_updated_at.strftime("%Y/%m/%d") + ' ' + (self.cond_updated_by.nil? ? "" : cond_updated_by.initials) 
  end
  
  def user_can_update(user)
    if user
      if (user.priv_write or self.users.collect{|usr| usr.id}.include?(user.id))
        true
      else
        false
      end
    else
      false
    end
  end
  
  def pallet_jack
    YesNoUnknown.new(read_attribute("pallet_jack"))
  end
  
  def fee_is_required?
    is_fee_required == 'Yes'
  end  
  
  def temporary_service?
    temp_perm == 'Temporary'
  end

  def service_temp_perm
    return "" if temp_perm.nil?
    out = temp_perm
    if temp_perm == 'Temporary' and not planned_enddate.blank?
      out << ' - Ending ' + planned_enddate.to_s
    end
    out
  end
  
  def has_client_contact_info?
    (not client_contact_address.blank?) || (not client_contact_phone.blank?) || (not client_contact_email.blank?) ||false
  end
  
  def waiting_list_text
    if waiting_list.blank? || waiting_list == 0
      "No"
    else
      out = "#{waiting_list} Weeks" 
      out <<  ("..." + waiting_list_explanation) if not waiting_list_explanation.blank?
      out
    end
  end

  def self.project_shelters(user, with_projects)
    cond = user.priv_write ? "" : "is_this_user(shelters.id, #{user.id}) and"
    cond += "exists(select * from projects where projects.shelter_id = shelters.id)" if with_projects
    Shelter.find(:all,
                 :select => "id,name",
                 :order => "name",
                 :conditions => cond == "" ? nil : cond)
  end
  
#-----new code above this line---------------------------------
  def self.sorts
    @@SORTS
  end

  def self.default_sort_name
    "Name"
  end

  def self.last_sort
    "Name"
  end

  def condition_items(cls=Condition)
    @condition_items ||= {}
    @condition_items[cls] ||= self.send(cls.to_s.pluralize.downcase).map { |c| c.item_id }
  end

  def surplus_items
    @surplus_items ||= surpluses.map { |c| c.item_id }
  end

  def self.shelter_ids_for(conditions = nil, order = nil)
    conditions = "WHERE " + sanitize_sql(conditions) if conditions
    order = "ORDER BY " + sanitize_sql(order) if order
    if conditions and conditions.index("shelters_users")
      tables = "shelters, shelters_users"
    else
      tables = "shelters"
    end
    ActiveRecord::Base.connection.select_all("SELECT shelters.id FROM #{tables} #{conditions} #{order};").map {|r| r['id'].to_i}
  end

  def self.find_with_upd_names(id)
    find_all_with_upd_names(["shelters.id = ?", id], nil, 1, nil)[0]
  end
  def self.find_all_with_upd_names(conditions = nil, order = nil, limit = nil, offset = nil)
    conditions = "WHERE " + sanitize_sql(conditions) if conditions
    order = "ORDER BY " + sanitize_sql(order) if order
    limit = "LIMIT #{sanitize_sql(limit)}" if limit
    offset = "OFFSET #{sanitize_sql(offset)}" if offset
    find_by_sql("SELECT shelters.*, u1.firstname AS updfn, u1.lastname AS updln, u2.firstname AS cupdfn, u2.lastname AS cupdln FROM shelters LEFT OUTER JOIN users u1 ON u1.id = shelters.updated_by_id LEFT OUTER JOIN users u2 ON u2.id = shelters.cond_updated_by_id #{conditions} #{order} #{limit} #{offset};")
  end

  def avail_matches(cond, sort)
    matches(true, cond, sort)
  end
  def need_matches(cond, sort)
    matches(false, cond, sort)
  end
  
  def matches(avail, cond=nil, order=nil)
    if avail
      type1 = 'Need'
      type2 = 'Surplus'
      my_load_field = 'source_id'
      their_load_field = 'destination_id'
    else
      type1 = 'Surplus'
      type2 = 'Need'
      my_load_field = 'destination_id'
      their_load_field = 'source_id'
    end
    cond &&= sanitize_sql(cond) + " AND "
    order &&= "ORDER BY " + sanitize_sql(order)
    if order
      distinct = order.split(/ |,/).delete_if {|s| not s =~ /([a-z]+[(])?[a-z]+[.]?[a-z]+[)]?/}
      distinct = distinct.push('conditions.id').join(', ')
    else
      distinct = 'conditions.id'
    end
    records = ActiveRecord::Base.connection.select_all("
      SELECT DISTINCT ON (#{distinct}) conditions.id,

          l.id AS latest_load_id
        FROM conditions, items, shelters
          LEFT OUTER JOIN (SELECT * FROM loads WHERE id IN
            (SELECT max(id) FROM loads WHERE loads.status = 0 AND loads.#{my_load_field} = #{id} GROUP BY loads.#{their_load_field})) l 
            ON l.#{their_load_field} = shelters.id
        WHERE #{cond} shelters.id = conditions.shelter_id
          AND shelters.id != #{id}
          AND conditions.item_id = items.id
          AND conditions.type = '#{type1}'
          AND #{Condition.show_conds}
          AND conditions.item_id IN
            (SELECT item_id FROM conditions WHERE shelter_id = #{id} AND type = '#{type2}' AND #{Condition.show_conds})
        #{order}
      ;")

    condids = records.map {|r| r['id'].to_i }
    distances = {}; records.each {|r| distances[r['id'].to_i] = r['distance'] }
    loads = {}; records.each {|r| loads[r['id'].to_i] = r['latest_load_id'] }
    return condids, distances, loads
  end

  def info_updated_txt
    if updfn and updln
      inits = User.abbrev_name(updfn, updln)
    else
      inits = safe_upd_by
    end
    "#{updated_at.month}/#{updated_at.mday} by #{inits}"
  end

  def conditions_updated_txt
    u = conditions_updated
    if u and u.size == 2
      "#{u[0].month}/#{u[0].mday} by #{u[1]}"
    elsif u and u.size == 1
      "#{u[0].month}/#{u[0].mday}"
    else
      ""
    end
  end

  def conditions_updated
    if cond_updated_at && cond_updated_by_id
      if cupdfn and cupdln
        inits = User.abbrev_name(cupdfn, cupdln)
      else
        inits = cond_updated_by.initials
      end
      return [cond_updated_at, inits]
    elsif cond_updated_at
      return [cond_updated_at]
    end
  end

  def update_cond(user)
    ActiveRecord::Base.connection.update("UPDATE shelters SET cond_updated_at = 'now', cond_updated_by_id = #{user.id.to_i} WHERE id = #{id.to_i};")
  end
 
  def set_def_cupd
    write_attribute('cond_updated_at', DateTime.now.new_offset)
  end

  def state=(str)
    write_attribute('state', str.upcase)
  end

  def website
    begin
      w = read_attribute('website')
      if not w.index('://')
        w = "http://" + w
      end
      uri = URI.parse(w)
      if uri.scheme != 'http' and uri.scheme != 'https'
	return nil
      end
      return uri.select(:scheme)[0] + "://" + uri.select(:host)[0] + uri.request_uri
    rescue
      return nil
    end
  end

  def txt_resources
    txt = ""
    for r in resources
      txt << r.kind + ": " + r.name + "\n"
    end
    return txt
  end

  def txt_resources=(txt)
    resources = Set.new
    txt.split(/[\r\n]+/).each do |line|
      kind, name = line.split(":").map {|s| s.strip}
      if kind and name and kind.size > 2 and name.size > 2 and not (kind + name).index(":") # Check no extra :s
        if resource = Resource.find_by_kind_and_name(kind, name)
          resources << resource
        else
          resource = Resource.new
          resource.name = name
          resource.kind = kind
          resource.set_updated_by(self.updated_by)
	  resource.save
	  resources << resource
	end
      end
    end
    self.resources = resources.to_a
  end

  def zip
    z = read_attribute('zip')
    z = ExtInteger.new(z)
    class << z
      def to_s
        # Always format the zipcode as 5 digits
        "%05d" % @val
      end
    end
    return z
  end
    
  def mailing_address
    name + "\n" + mailing_address_without_name
  end
 
  def mailing_address_without_name
    (address.blank? ? "" : address + "\n") + town + ", " + state + " " + zip.to_s
  end

  def mapping_address
    if address && town && state && address.size > 1
      return address.split(/(\r|\n)/)[0].delete("'") + ", " + town + ", " + state
    else
      return nil
    end
  end

  def update_address
    begin
      if a = mapping_address
        latlong = GeoCode::geocode(a)
      else
        latlong = nil
      end
      if latlong != nil
        self.latitude = latlong[0]
        self.longitude = latlong[1]
      else
        self.latitude = self.longitude = nil
      end
    rescue
    end
  end

  def self.markers_for(shelters, selected=nil)
    markers = {}
    i = 0
    for shelter in shelters
      if shelter.latitude != nil
	#marker_text = (h(shelter.mailing_address.delete("'")) + ' <A HREF="/shelters/show/' + shelter.id.to_s + '" TARGET="_top" onclick="return shelterdetails(' + shelter.id.to_s + ');">(details)</A>').gsub("\n", "<br />").delete("\r")
	marker_text = (h(shelter.mailing_address.delete("'")) + ' <A HREF="javascript:void(0)" onclick="return shelterdetails(' + shelter.id.to_s + ');">(details)</A>').gsub("\n", "<br />").delete("\r")
	markers[i] = [[shelter.longitude, shelter.latitude], marker_text, shelter.status.color, shelter.id == (selected and selected.id)]
      end
      i += 1
    end
    return markers
  end

  def self.icon_for(shelter, shelter_ids)
    return "" if not shelter.latitude
    if shelter_ids.nil?
      i = -1
    else
      #shelters = shelters.reject {|s| s.latitude == nil}
      i = shelter_ids.index(shelter.id)
      #if not i
      #  return ""
      #end
    end
    return '<a href="javascript:void(0)"><img src="' + GmapHelper.map_icon_number(i, shelter.status.color) + '" onclick="sheltermap(' + shelter.longitude.to_s + ', ' + shelter.latitude.to_s + ')" border="0"></a>'
  end

  def self.text_icon_for(shelter)
    js = '<SCRIPT type="text/javascript">writeIconLet()</SCRIPT>'
    if not shelter.latitude
      return "<span style=\"display:none\">#{js}</span>"
    end
    href = 'javascript:sheltermap(' + shelter.longitude.to_s + ', ' + shelter.latitude.to_s + ')'
    return "<a href=\"#{href}\">#{js}</a>"
  end

  def self.text_icon_for_STUPID(controller, shelterid, shelter_ids)
    if not href = controller.read_fragment("shelters/latlonghref/#{shelterid}")
      shelter = Shelter.find(shelterid)
      if shelter.latitude
        href = 'javascript:sheltermap(' + shelter.longitude.to_s + ', ' + shelter.latitude.to_s + ')'
      else
        href = ""
      end
      controller.write_fragment("shelters/latlonghref/#{shelterid}", href)
    end
    if href == ""
      return href
    end
    i = shelter_ids.index(shelterid)
    return '<a href="' + href + '">' + GmapHelper.map_letter_number(i) + '</a>'
  end

  class RedCrossStatus < LevelSetting
    @levels = { 0 => "Unknown", 1 => "Red Cross Shelter", 2 => "Within 10 Min", 3 => "Have Contacted", 4 => "Have Not Contacted" }
  end

  def red_cross_status
    RedCrossStatus.new(read_attribute("red_cross_status"))
  end

  class Status < ColoredLevelSetting
    @levels = { 0 => "Unknown", 1 => "Open", 2 => "Standby", 3=> "Closed" }
    @colors = { 0 => "gray", 1 => "green", 2 => "purple", 3 => "red"}
  end

  def status
    Status.new(read_attribute("status"))
  end

  def self.status(status)
    Status.levels[status.to_i]
  end

  class FacilityType < ColoredLevelSetting
    @levels = { 0 => "Unknown", 1 => "Shelter", 2 => "Walk-in Resource", 3 => "Warehouse", 4 => "Donor", 5 => "Unassigned Region/Area", 6 => "Info/Hotline", 7 => "Animal Shelter", 9=> "Supply POD", 10=> "School", 11 => "Open Business*", 12=> "Volunteer Camp", 13 => "Family/Individual", 14=>"Medical Facility", 15=>"Database Training/Admin" }
    @colors = { 0 => "#EEEEEE", 1 => "#FFFFEE", 2 => "#E3FBE9", 3 => "#FFEEFF", 4 => "#EEDDFF", 5 => "#FFEEDD", 6 => "#EEFFFF", 7 => "#FFEEEE", 8 => "#DDEEFF", 9 => "#EEEEFF", 10 => "#FFDDBB", 11 => "#FFAAAA", 12 => "#DDEEFF", 13 => "#CCFFEE", 14=> "#F5EA00", 14=> "#F5EA00" }
  end

  def facility_type
    FacilityType.new(read_attribute("facility_type"))
  end

  def self.facility_type(facility_type)
    FacilityType.levels[facility_type.to_i]
  end

  def dc_more
    YesNoUnknown.new(read_attribute("dc_more"))
  end

  def loading_dock
    YesNoUnknown.new(read_attribute("loading_dock"))
  end

  def forklift
    YesNoUnknown.new(read_attribute("forklift"))
  end

  def sensitive_access?(attr)
    return [:mgt_contact, :supply_contact, :mgt_phone, :supply_phone, :other_contacts, :email].include?(attr.to_sym)
  end

  def trust_user?(user)
    self.users.include?(user)
  end

  def mgt_phone(user)
    sensitive_access("mgt_phone", user)
  end

  def supply_phone(user)
    sensitive_access("supply_phone", user)
  end

  def mgt_contact(user)
    sensitive_access("mgt_contact", user)
  end

  def supply_contact(user)
    sensitive_access("supply_contact", user)
  end

  def other_contacts(user)
    sensitive_access("other_contacts", user)
  end

  def email(user)
    sensitive_access("email", user)
  end

  def allowed_write?(user)
    user and (user.priv_write or users.include?(user))
  end

end

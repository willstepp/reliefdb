class Facility < ActiveRecord::Base
  set_primary_key :id 
  set_table_name = "shelters"
  has_many :users
       
  def self.cols
    ["shelters.name","shelters.organization","shelters.main_phone","shelters.state","shelters.region",
       "shelters.parish","shelters.town","shelters.status","shelters.updated_at","shelters.cond_updated_at","shelters.facility_type"]
  end
  
  def self.col_names
    ["Name","Org","Main Phone","State","Region",
       "County","City/Town","Status","Last Update","Last Item Update","Type"]
  end
  
  def self.col_for_sort
    ["upper(shelters.name)","upper(shelters.organization)","shelters.main_phone","upper(shelters.state)","upper(shelters.region)",
       "upper(shelters.parish)","upper(shelters.town)","shelters.status","shelters.updated_at","shelters.cond_updated_at","shelters.facility_type"]
  end
  
  def self.sort_order
    ["ASC","ASC","ASC","ASC","ASC","ASC","ASC","ASC","DESC","DESC","ASC"]
  end  

end

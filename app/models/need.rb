class Need < Condition
  #set_primary_key :id 
  
  before_update :update_history
  after_create :update_history

  class Urgency < LevelSetting
    @levels = { 1 => "Very Urgent", 2 => "Urgent", 3 => "Average", 4 => "Not Urgent" }
  end

  def urgency
    Urgency.new(read_attribute("urgency"))
  end

  class CratePreference < LevelSetting
    @levels = { 0 => "Unknown", 1 => "Individual Only", 2 => "Crates or Individual", 3 => "Prefer Crates", 4 => "Crates Only" }
  end

  def crate_preference
    CratePreference.new(read_attribute("crate_preference"))
  end

  class CanBuyLocal < LevelSetting
    @levels = { 0 => "Unknown", 1 => "No", 2 => "Yes", 3=> "Difficult" }
  end

  def can_buy_local
    CanBuyLocal.new(read_attribute("can_buy_local"))
  end

  def qty
    begin
      qty_needed.to_i || 0
    rescue
      return 0
    end
  end
  def qty=(n)
    if qty_needed == nil and n == 0
      return 0
    end
    write_attribute("qty_needed", n)
  end

end

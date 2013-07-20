class ShelterSweeper < ActionController::Caching::Sweeper
  observe Shelter, Condition, Need, Surplus
 
  def after_save(record)
    if record.is_a?(Condition)
      id = record.shelter_id
    elsif record.is_a?(Shelter)
      id = record.id
    else
      return false
    end
    expire_fragment("shelters/list/#{id}")
  end
end

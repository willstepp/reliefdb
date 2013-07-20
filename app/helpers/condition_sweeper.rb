class ConditionSweeper < ActionController::Caching::Sweeper
  observe Shelter, Condition, Need, Surplus, Item
 
  def after_save(record)
    if record.is_a?(Condition)
      ids = [record.id]
    elsif record.is_a?(Shelter)
      ids = ActiveRecord::Base.connection.select_all("SELECT conditions.id FROM conditions WHERE conditions.shelter_id = #{record.id};").map {|r| r['id']}
    elsif record.is_a?(Item)
      ids = ActiveRecord::Base.connection.select_all("SELECT conditions.id FROM conditions WHERE conditions.item_id = #{record.id};").map {|r| r['id']}
    else
      return false
    end
    ids.each { |id| expire_fragment("conditions/list/#{id}") }
  end
end

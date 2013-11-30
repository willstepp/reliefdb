class AddFacilityIdToLoad < ActiveRecord::Migration
  def change
    add_column :loads, :facility_id, :integer
  end
end

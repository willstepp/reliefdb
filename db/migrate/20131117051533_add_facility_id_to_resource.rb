class AddFacilityIdToResource < ActiveRecord::Migration
  def change
    add_column :resources, :facility_id, :integer
  end
end

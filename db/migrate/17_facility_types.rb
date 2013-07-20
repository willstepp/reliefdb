class FacilityTypes < ActiveRecord::Migration
  def self.up
    add_column :shelters, :facility_type, :integer
    execute "UPDATE shelters SET facility_type = 0;"
  end

  def self.down
    remove_column :shelters, :facility_type
  end
end

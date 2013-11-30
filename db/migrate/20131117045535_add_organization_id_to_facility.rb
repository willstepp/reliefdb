class AddOrganizationIdToFacility < ActiveRecord::Migration
  def change
    add_column :facilities, :organization_id, :integer
  end
end

class ChangeOrganizationColumnTypes < ActiveRecord::Migration
  def change
    change_column :organizations, :name, :text, :limit => nil
  end
end

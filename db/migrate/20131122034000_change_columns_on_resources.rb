class ChangeColumnsOnResources < ActiveRecord::Migration
  def change
    change_column :resources, :description, :text, :limit => nil
  end
end

class ChangeFacilitiesColumnTypes < ActiveRecord::Migration
  def change
    change_column :facilities, :website, :text, :limit => nil
    change_column :facilities, :phone, :text, :limit => nil
    change_column :facilities, :address, :text, :limit => nil
    change_column :facilities, :contact_name, :text, :limit => nil
  end
end

class ChangeItemsColumnsToText < ActiveRecord::Migration
  def change
    change_column :items, :name, :text, :limit => nil
    change_column :items, :description, :text, :limit => nil
  end
end

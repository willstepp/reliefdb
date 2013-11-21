class ChangeCategoriesColumnsToText < ActiveRecord::Migration
  def change
    change_column :categories, :name, :text, :limit => nil
    change_column :categories, :description, :text, :limit => nil
  end
end

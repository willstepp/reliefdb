class JoinTableForItemsAndCategories < ActiveRecord::Migration
  def change
    create_table :categories_items do |t|
      t.belongs_to :category
      t.belongs_to :item
    end
  end
end

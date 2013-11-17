class JoinTableForResourcesAndCategories < ActiveRecord::Migration
  def change
    create_table :categories_resources do |t|
      t.belongs_to :category
      t.belongs_to :resource
    end
  end
end

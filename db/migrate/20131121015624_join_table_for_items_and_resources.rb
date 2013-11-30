class JoinTableForItemsAndResources < ActiveRecord::Migration
  def change
    create_table :items_resources do |t|
      t.belongs_to :item
      t.belongs_to :resource
    end
  end
end

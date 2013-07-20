class ItemsPerPallet < ActiveRecord::Migration
  def self.up
    add_column :items, :qty_per_pallet, :integer
  end

  def self.down
    remove_column :items, :qty_per_pallet
  end
end

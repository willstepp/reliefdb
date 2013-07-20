class CanBuyLocalInt < ActiveRecord::Migration
  def self.up
    rename_column :conditions, :can_buy_local, :can_buy_local_old
    add_column :conditions, :can_buy_local, :integer
    execute "UPDATE conditions SET can_buy_local = 2 WHERE can_buy_local_old = true;"
    remove_column :conditions, :can_buy_local_old
  end

  def self.down
  end
end

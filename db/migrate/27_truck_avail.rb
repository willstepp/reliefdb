class TruckAvail < ActiveRecord::Migration
  def self.up
    add_column :loads, :transport_avail, :integer
  end

  def self.down
    remove_column :loads, :transport_avail, :integer
  end
end

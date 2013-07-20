class IntermediateWarehouse < ActiveRecord::Migration
  def self.up
    add_column :loads, :routing_type, :integer
  end

  def self.down
    remove_column :loads, :routing_type
  end
end

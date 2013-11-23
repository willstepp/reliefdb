class AddColumnsToLoads < ActiveRecord::Migration
  def change
    change_column :loads, :description, :text, :limit => nil
    change_column :loads, :stock, :text, :limit => nil

    add_column :loads, :info_source, :text, :limit => nil
    add_column :loads, :notes, :text, :limit => nil
    add_column :loads, :source_id, :integer
    add_column :loads, :destination_id, :integer

    add_column :loads, :title, :text, :limit => nil
    add_column :loads, :trucker_name, :text, :limit => nil
    add_column :loads, :truck_reg, :text, :limit => nil
    add_column :loads, :status, :integer
    add_column :loads, :ready_by, :datetime
    add_column :loads, :etd, :datetime
    add_column :loads, :eta, :datetime
    add_column :loads, :transport_avail, :integer
    add_column :loads, :routing_type, :integer
  end
end

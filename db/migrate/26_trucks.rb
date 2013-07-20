class Trucks < ActiveRecord::Migration
  def self.up
    add_column :conditions, :load_id, :integer

    create_table :loads do |t|
      t.column :created_at,     :datetime
      t.column :updated_at,     :datetime
      t.column :updated_by_id, :integer
      t.column :lock_version,   :integer,       :default => 0
      t.column :info_source,  :text
      t.column :notes, :text
      t.column :source_id, :integer
      t.column :destination_id, :integer
      t.column :title, :string
      t.column :trucker_name, :string
      t.column :truck_reg, :string
      t.column :status, :integer
      t.column :ready_by, :datetime
      t.column :etd, :datetime
      t.column :eta, :datetime
    end

    execute "ALTER TABLE loads ADD FOREIGN KEY (source_id) REFERENCES shelters(id);"
    execute "ALTER TABLE loads ADD FOREIGN KEY (destination_id) REFERENCES shelters(id);"
    execute "ALTER TABLE loads ALTER source_id SET NOT NULL;"
    execute "ALTER TABLE conditions ADD FOREIGN KEY (load_id) REFERENCES loads(id);"
  end

  def self.down
    remove_column :conditions, :load_id
    drop_table :loads
  end
end

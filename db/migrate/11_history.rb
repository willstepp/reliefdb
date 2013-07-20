class History < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.column :timestamp, :datetime
      t.column :objtype, :string
      t.column :objid, :integer
      t.column :updated_by_id, :integer
      t.column :update_desc, :text
      t.column :obj, :text
    end

    execute "ALTER TABLE histories ADD FOREIGN KEY (updated_by_id) REFERENCES users(id);"
    execute "ALTER TABLE histories ALTER updated_by_id SET NOT NULL;"

  end

  def self.down
    drop_table :histories
  end
end

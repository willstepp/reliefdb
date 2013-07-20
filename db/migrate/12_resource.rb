class Resource < ActiveRecord::Migration
  def self.up
    create_table :resources do |t|
      t.column :created_at,     :datetime
      t.column :updated_at,     :datetime
      t.column :updated_by_id, :integer
      t.column :lock_version,   :integer,       :default => 0
      t.column :name,   :string
      t.column :kind,   :string
      t.column :notes,  :text
    end

    execute "ALTER TABLE resources ADD FOREIGN KEY (updated_by_id) REFERENCES users(id);"
    execute "ALTER TABLE resources ALTER updated_by_id SET NOT NULL;"
 
    create_table :resources_shelters, :id => false do |t|
      t.column :resource_id,    :integer
      t.column :shelter_id,        :integer
    end

    execute "ALTER TABLE resources_shelters ADD FOREIGN KEY (resource_id) REFERENCES resources(id);"
    execute "ALTER TABLE resources_shelters ADD FOREIGN KEY (shelter_id) REFERENCES shelters(id);"
    execute "ALTER TABLE resources_shelters ALTER resource_id SET NOT NULL;"
    execute "ALTER TABLE resources_shelters ALTER shelter_id SET NOT NULL;"

  end

  def self.down
    drop_table :resources_shelters
    drop_table :resources
  end
end

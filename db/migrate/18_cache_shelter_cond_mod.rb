class CacheShelterCondMod < ActiveRecord::Migration
  def self.up
    add_column :shelters, :cond_updated_at, :datetime
    add_column :shelters, :cond_updated_by_id, :integer

    execute "ALTER TABLE shelters ADD FOREIGN KEY (cond_updated_by_id) REFERENCES users(id);"
  end

  def self.down
    remove_column :shelters, :cond_updated_at
    remove_column :shelters, :cond_updated_by_id
  end
end

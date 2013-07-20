class UpdatedBy < ActiveRecord::Migration
  def self.up
    add_column :shelters, :updated_by_id, :integer
    add_column :conditions, :updated_by_id, :integer
    add_column :items, :updated_by_id, :integer
    add_column :categories, :updated_by_id, :integer

    execute "ALTER TABLE shelters ADD FOREIGN KEY (updated_by_id) REFERENCES users(id);"
    execute "ALTER TABLE conditions ADD FOREIGN KEY (updated_by_id) REFERENCES users(id);"
    execute "ALTER TABLE items ADD FOREIGN KEY (updated_by_id) REFERENCES users(id);"
    execute "ALTER TABLE categories ADD FOREIGN KEY (updated_by_id) REFERENCES users(id);"

  end

  def self.down
    remove_column :shelters, :updated_by_id
    remove_column :conditions, :updated_by_id
    remove_column :items, :updated_by_id
    remove_column :categories, :updated_by_id
  end
end

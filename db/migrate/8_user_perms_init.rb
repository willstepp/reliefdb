class UserPermsInit < ActiveRecord::Migration
  def self.up
    add_column :users, :priv_admin, :boolean
    add_column :users, :priv_write, :boolean
    add_column :users, :priv_read, :boolean
    add_column :users, :priv_read_sensitive, :boolean

    create_table :shelters_users do |t|
      t.column :shelter_id,    :integer
      t.column :user_id,        :integer
    end

    execute "ALTER TABLE shelters_users ADD FOREIGN KEY (shelter_id) REFERENCES shelters(id);"
    execute "ALTER TABLE shelters_users ADD FOREIGN KEY (user_id) REFERENCES users(id);"
    execute "ALTER TABLE shelters_users ALTER shelter_id SET NOT NULL;"
    execute "ALTER TABLE shelters_users ALTER user_id SET NOT NULL;"

  end

  def self.down
    remove_column :users, :priv_admin
    remove_column :users, :priv_write
    remove_column :users, :priv_read
    remove_column :users, :priv_read_sensitive

    drop_table :shelters_users
  end
end

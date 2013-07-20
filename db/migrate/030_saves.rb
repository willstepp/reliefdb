class Saves < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      # t.column :name, :string
      t.column :user_id, :integer
      t.column :save_name, :string, :limit => 30 
      t.column :save_data, :text
      t.column :created_on, :timestamp
      t.column :updated_on, :timestamp
    end
    
    execute "ALTER TABLE searches ADD FOREIGN KEY (user_id) REFERENCES users(id);"
#    execute "ALTER TABLE searches ALTER user_id SET NOT NULL;"
  end

  def self.down
    drop_table :searches
  end
end

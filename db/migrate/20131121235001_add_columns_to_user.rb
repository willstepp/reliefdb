class AddColumnsToUser < ActiveRecord::Migration
  def change
    add_column :users, :username, :text, :limit => nil
    add_column :users, :first_name, :text, :limit => nil
    add_column :users, :last_name, :text, :limit => nil
  end
end

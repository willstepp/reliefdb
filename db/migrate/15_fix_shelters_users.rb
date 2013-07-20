class FixSheltersUsers < ActiveRecord::Migration
  def self.up
    remove_column :shelters_users, :id
  end

  def self.down
  end
end

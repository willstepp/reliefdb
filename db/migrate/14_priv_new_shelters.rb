class PrivNewShelters < ActiveRecord::Migration
  def self.up
    add_column :users, :priv_new_shelters, :boolean
  end

  def self.down
    remove :users, :priv_new_shelters
  end
end

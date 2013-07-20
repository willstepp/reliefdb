class NewShelterFields < ActiveRecord::Migration
  def self.up
    add_column :shelters, :red_cross_status, :integer
    add_column :shelters, :region, :string
    add_column :shelters, :capacity, :integer
    add_column :shelters, :current_population, :integer
  end

  def self.down
    remove_column :shelters, :red_cross_status
    remove_column :shelters, :region
    remove_column :shelters, :capacity
    remove_column :shelters, :current_population
  end
end

class NewColumns < ActiveRecord::Migration
  def self.up
    add_column :conditions, :packaged_as, :string, :limit => 20
    add_column :shelters, :pallet_jack, :integer
  end

  def self.down
    remove_column :conditions, :packaged_as
    remove_column :shelters, :pallet_jack  
  end
end

class NeedLevelsToInt < ActiveRecord::Migration
  def self.up
    remove_column :conditions, :urgency
    remove_column :conditions, :crate_preference
    add_column :conditions, :urgency, :integer
    add_column :conditions, :crate_preference, :integer
  end

  def self.down
    drop_column :conditions, :urgency
    drop_column :conditions, :crate_preference
    add_column :conditions, :urgency, :string
    add_column :conditions, :crate_preference, :string
  end
end

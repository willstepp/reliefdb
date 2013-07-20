class LatLong < ActiveRecord::Migration
  def self.up
    add_column :shelters, :latitude, :float
    add_column :shelters, :longitude, :float
  end

  def self.down
    drop_column :shelters, :latitude
    drop_column :shelters, :longitude
  end
end

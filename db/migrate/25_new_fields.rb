class NewFields < ActiveRecord::Migration
  def self.up
    add_column :shelters, :hours, :string
    add_column :shelters, :email, :string
    add_column :shelters, :loading_dock, :integer
    add_column :shelters, :forklift, :integer
    add_column :shelters, :workers, :integer
  end

  def self.down
  end
end

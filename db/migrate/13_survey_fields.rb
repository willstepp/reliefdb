class SurveyFields < ActiveRecord::Migration
  def self.up
    add_column :shelters, :status, :integer
    add_column :shelters, :organization, :string
    add_column :shelters, :dc_population, :integer
    add_column :shelters, :dc_shelters, :integer
    add_column :shelters, :dc_more, :boolean
    add_column :conditions, :can_buy_local, :boolean
  end

  def self.down
    remove_column :shelters, :status
    remove_column :shelters, :organization
    remove_column :shelters, :dc_population
    remove_column :shelters, :dc_shelters
    remove_column :shelters, :dc_more
    remove_column :conditions, :can_buy_local
  end
end

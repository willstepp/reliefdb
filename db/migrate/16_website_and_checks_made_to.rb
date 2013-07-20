class WebsiteAndChecksMadeTo < ActiveRecord::Migration
  def self.up
    add_column :shelters, :website, :string
    add_column :shelters, :make_payable_to, :string
  end

  def self.down
    remove_column :shelters, :website
    remove_column :shelters, :make_payable_to
  end
end

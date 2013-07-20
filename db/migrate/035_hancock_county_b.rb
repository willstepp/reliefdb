class HancockCountyB < ActiveRecord::Migration
  def self.up
    add_column :shelters, :fee_is_for, :string
    add_column :shelters, :mission, :text
    add_column :shelters, :cat_notes, :text
    execute "ALTER TABLE shelters ALTER fee_amount TYPE numeric(7, 2);"
  end

  def self.down
    remove_column :shelters, :fee_is_for
    remove_column :shelters, :mission
    remove_column :shelters, :cat_notes
  end
end

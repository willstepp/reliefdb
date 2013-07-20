class InfoSource < ActiveRecord::Migration
  def self.up
    add_column :shelters, :info_source, :text
    add_column :conditions, :info_source, :text
  end

  def self.down
    remove_column :shelters, :info_source
    remove_column :conditions, :info_source
  end
end

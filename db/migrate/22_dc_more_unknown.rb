class DcMoreUnknown < ActiveRecord::Migration
  def self.up
    rename_column :shelters, :dc_more, :dc_more_old
    add_column :shelters, :dc_more, :integer
    execute "UPDATE shelters SET dc_more = 2 WHERE dc_more_old = true;"
    remove_column :shelters, :dc_more_old
  end

  def self.down
  end
end

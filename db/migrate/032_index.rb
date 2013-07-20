class Index < ActiveRecord::Migration
  def self.up   
    execute "create index item_id ON conditions (item_id);"
    
  end

  def self.down
    execute "DROP INDEX item_id;"

  end
end

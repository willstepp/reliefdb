class ForeignKeys < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE conditions ADD FOREIGN KEY (shelter_id) REFERENCES shelters(id);"
    execute "ALTER TABLE conditions ADD FOREIGN KEY (item_id) REFERENCES items(id);"
    execute "ALTER TABLE categories_items ADD FOREIGN KEY (item_id) REFERENCES items(id);"
    execute "ALTER TABLE categories_items ADD FOREIGN KEY (category_id) REFERENCES categories(id);"
    execute "ALTER TABLE conditions ALTER shelter_id SET NOT NULL;"
    execute "ALTER TABLE conditions ALTER item_id SET NOT NULL;"
    execute "ALTER TABLE categories_items ALTER item_id SET NOT NULL;"
    execute "ALTER TABLE categories_items ALTER category_id SET NOT NULL;"
  end

  def self.down
  end
end

class AddIndexesToQueryTables < ActiveRecord::Migration
  def change
    add_index :facilities, :id
    add_index :facilities, :latitude
    add_index :facilities, :longitude
    add_index :resources, :id
    add_index :tags, :id
    add_index :resources_tags, :tag_id
    add_index :resources_tags, :resource_id
  end
end

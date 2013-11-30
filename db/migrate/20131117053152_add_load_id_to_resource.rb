class AddLoadIdToResource < ActiveRecord::Migration
  def change
    add_column :resources, :load_id, :integer
  end
end

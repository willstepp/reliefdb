class CreateResources < ActiveRecord::Migration
  def change
    create_table :resources do |t|
      t.string :description

      t.timestamps
    end
  end
end

class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :description
      t.string :stock

      t.timestamps
    end
  end
end

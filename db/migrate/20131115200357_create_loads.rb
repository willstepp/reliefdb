class CreateLoads < ActiveRecord::Migration
  def change
    create_table :loads do |t|
      t.string :description
      t.string :stock

      t.timestamps
    end
  end
end

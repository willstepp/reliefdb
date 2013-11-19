class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :description

      t.timestamps
    end
  end
end

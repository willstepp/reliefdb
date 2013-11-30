class CreateFacilities < ActiveRecord::Migration
  def change
    create_table :facilities do |t|
      t.string :website
      t.string :phone
      t.string :address
      t.boolean :headquarters
      t.string :contact_name
      t.string :twitter
      t.string :facebook

      t.timestamps
    end
  end
end

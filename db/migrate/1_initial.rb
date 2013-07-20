class Initial < ActiveRecord::Migration
  def self.up
    create_table :shelters do |t|
      t.column :created_at,	:datetime
      t.column :updated_at,	:datetime
      t.column :lock_version,	:integer,	:default => 0
      t.column :state,	:string,	:limit => 2
      t.column :parish,	:string
      t.column :town,	:string
      t.column :name,	:string
      t.column :DC,	:boolean
      t.column :main_phone,	:string
      t.column :mgt_contact,	:string
      t.column :mgt_phone,	:string
      t.column :supply_contact,	:string
      t.column :supply_phone,	:string
      t.column :address,	:text
      t.column :notes,	:text
    end

    create_table :conditions do |t|
      t.column :created_at,	:datetime
      t.column :updated_at,	:datetime
      t.column :lock_version,	:integer,	:default => 0
      t.column :type,	:string
      t.column :shelter_id,	:integer
      t.column :item_id,	:integer
      t.column :notes,	:text
      # Need fields
      t.column :qty_needed,	:integer
      t.column :crate_preference,	:string
      t.column :urgency,	:string
      # Surplus fields
      t.column :surplus_individual,	:integer
      t.column :surplus_crates,	:integer
      t.column :qty_per_crate,	:integer
      t.column :must_dispose_of_urgently,	:boolean
    end

    create_table :categories do |t|
      t.column :created_at,	:datetime
      t.column :updated_at,	:datetime
      t.column :lock_version,	:integer,	:default => 0
      t.column :name,	:string
      t.column :notes,	:text
    end

    create_table :items do |t|
      t.column :created_at,	:datetime
      t.column :updated_at,	:datetime
      t.column :lock_version,	:integer,	:default => 0
      t.column :name,	:string
      t.column :notes,	:text
    end

    create_table :categories_items, :id => false do |t|
      t.column :category_id,	:integer
      t.column :item_id,	:integer
    end
  end

  def self.down
    drop_table :shelters
    drop_table :conditions
    drop_table :categories
    drop_table :items
    drop_table :categories_items
  end
end

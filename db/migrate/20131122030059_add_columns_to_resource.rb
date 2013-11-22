class AddColumnsToResource < ActiveRecord::Migration
  def change
    add_column :resources, :type, :text, :limit => nil
    add_column :resources, :notes, :text, :limit => nil
    add_column :resources, :qty_needed, :integer
    add_column :resources, :surplus_individual, :integer

    add_column :resources, :surplus_crates, :integer
    add_column :resources, :qty_per_crate, :integer
    add_column :resources, :must_dispose_of_urgently, :boolean
    add_column :resources, :urgency, :integer

    add_column :resources, :crate_preference, :integer
    add_column :resources, :can_buy_local, :integer
    add_column :resources, :packaged_as, :text, :limit => nil
  end
end

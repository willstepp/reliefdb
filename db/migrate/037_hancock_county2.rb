class HancockCounty2 < ActiveRecord::Migration
  def self.up
    add_column :shelters, :clients_must_bring, :string
    add_column :shelters, :fee_explanation, :string
    add_column :shelters, :temp_perm_explanation, :string
    add_column :shelters, :waiting_list_explanation, :string
  end

  def self.down
    remove_column :shelters, :clients_must_bring
    remove_column :shelters, :fee_explanation
    remove_column :shelters, :temp_perm_explanation
    remove_column :shelters, :waiting_list_explanation
    
  end
end
